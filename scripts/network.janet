(import spork/json)
(import spork/sh :as shell)

# nmcli and mmcli come from the system PATH, like vpn's tailscale: they only
# mean anything next to the system's own daemons.

(defn run [args &opt input]
  (try
    (if-let [exec (dyn :network-exec)]
      (exec args input)
      (if input
        (with [proc (os/spawn args :p {:in :pipe :out :pipe :err :pipe})]
          (ev/write (proc :in) input)
          (ev/close (proc :in))
          (let [[out err status] (ev/gather (ev/read (proc :out) :all)
                                            (ev/read (proc :err) :all)
                                            (os/proc-wait proc))]
            {:out (string/trimr (or out "")) :err (string/trimr (or err "")) :status status}))
        (shell/exec-slurp-all ;args)))
    ([e] {:out "" :err (string e) :status 127})))

(defn slurp-ok [& args]
  (def result (run args))
  (when (zero? (result :status)) (result :out)))

(defn lines [out]
  (filter |(not (empty? $)) (string/split "\n" (or out ""))))

# `nmcli -t -e yes` separates fields with `:` and escapes `:` and `\` in values.
(def terse-peg
  '{:esc (* "\\" (<- 1))
    :char (+ :esc (<- (if-not ":" 1)))
    :field (% (any :char))
    :main (* :field (any (* ":" :field)) -1)})

(defn fields [line] (peg/match terse-peg line))

(defn terse [out keys]
  (map (fn [line] (table ;(interleave keys (fields line)))) (lines out)))

(defn devices [out]
  (map (fn [d] (put d :state (first (string/split " " (d :state)))))
       (terse out [:device :type :state :connection])))

(defn radios [out]
  (when-let [line (first (lines out))]
    (def [wifi-hw wifi wwan-hw wwan] (fields line))
    {:wifi-hw (= wifi-hw "enabled") :wifi (= wifi "enabled")
     :wwan-hw (= wwan-hw "enabled") :wwan (= wwan "enabled")}))

(defn connections [out] (terse out [:name :type]))

# Strongest entry per SSID, the one in use first; hidden networks have no SSID.
(defn networks [out]
  (def best @{})
  (each n (terse out [:in-use :ssid :security :signal])
    (def n (merge n {:in-use (= (n :in-use) "*")
                     :signal (or (scan-number (n :signal)) 0)}))
    (def seen (best (n :ssid)))
    (unless (or (empty? (n :ssid))
                (and seen (or (seen :in-use) (and (not (n :in-use)) (>= (seen :signal) (n :signal))))))
      (put best (n :ssid) n)))
  (sort (values best)
        (fn [a b] (if (= (a :in-use) (b :in-use)) (> (a :signal) (b :signal)) (a :in-use)))))

(defn modem [out]
  (when out
    (def info @{})
    (each line (lines out)
      (when-let [[k v] (peg/match '(* (<- (some (if-not (set " :") 1))) :s* ":" :s* (<- (any 1))) line)]
        (def v (string/trim v))
        (unless (= v "--") (put info k v))))
    (unless (empty? info) info)))

(defn technology [info]
  (def techs (seq [[k v] :pairs info :when (string/has-prefix? "modem.generic.access-technologies.value" k)] v))
  (cond
    (some |(= "5gnr" $) techs) "5G"
    (some |(= "lte" $) techs) "LTE"
    (some |(string/has-prefix? "hspa" $) techs) "3G"
    (some |(= "umts" $) techs) "3G"
    (empty? techs) nil
    "2G"))

(defn modem-signal [info]
  (scan-number (or (get info "modem.generic.signal-quality.value") "")))

# Why a modem with a profile still can't connect, in the user's words.
(defn modem-problem [info]
  (def state (get info "modem.generic.state"))
  (def reason (get info "modem.generic.state-failed-reason"))
  (cond
    (= reason "sim-missing") "No SIM card"
    (= reason "sim-error") "SIM card error"
    (= state "failed") (string "Modem failed" (if reason (string " · " reason) ""))
    (= state "locked") "SIM locked · PIN required"
    (= (get info "modem.generic.power-state") "low") "Radio off (low power or FCC lock)"))

(def wifi-glyphs ["󰤯" "󰤟" "󰤢" "󰤥" "󰤨"])
(def cell-glyphs ["󰢿" "󰢼" "󰢽" "󰢾"])
(defn level [glyphs signal]
  (get glyphs (min (dec (length glyphs)) (math/floor (/ (* (or signal 0) (length glyphs)) 101)))))

(defn short [s]
  (if (> (length s) 16) (string (string/slice s 0 15) "…") s))

(defn capitalize [s] (string (string/ascii-upper (string/slice s 0 1)) (string/slice s 1)))

(defn join [& parts] (string/join (filter |(and $ (not (empty? $))) parts) " · "))

(defn snapshot [&opt rescan]
  (def nm-devices (slurp-ok "nmcli" "-t" "-e" "yes" "-f" "DEVICE,TYPE,STATE,CONNECTION" "device"))
  (when nm-devices
    (def r (radios (slurp-ok "nmcli" "-t" "-f" "WIFI-HW,WIFI,WWAN-HW,WWAN" "radio")))
    (def ds (devices nm-devices))
    (def has-wifi (some |(= "wifi" ($ :type)) ds))
    (def has-modem (some |(= "gsm" ($ :type)) ds))
    {:devices ds
     :radios r
     :connections (connections (slurp-ok "nmcli" "-t" "-e" "yes" "-f" "NAME,TYPE" "connection" "show"))
     :networks (if (and has-wifi (get r :wifi))
                 (networks (slurp-ok "nmcli" "-t" "-e" "yes" "-f" "IN-USE,SSID,SECURITY,SIGNAL"
                                     "device" "wifi" "list" "--rescan" (if rescan "yes" "no")))
                 @[])
     :modem (when has-modem (modem (slurp-ok "mmcli" "-m" "any" "--output-keyvalue")))}))

(defn link [s d]
  (case (d :type)
    "ethernet" {:icon "󰈀" :text "wired" :tooltip (join "Ethernet" (d :device) (d :connection))}
    "wifi" (let [n (find |($ :in-use) (s :networks))
                 signal (when n (n :signal))]
             {:icon (level wifi-glyphs signal) :text (short (d :connection))
              :tooltip (join "Wi-Fi" (d :connection) (when signal (string signal "%")))})
    "gsm" (let [info (or (s :modem) {})
                signal (modem-signal info)
                tech (technology info)]
            {:icon (level cell-glyphs signal) :text (or tech "mobile")
             :tooltip (join "Mobile" (get info "modem.3gpp.operator-name") tech (when signal (string signal "%")))})))

(def link-types ["ethernet" "wifi" "gsm"])
(defn by-preference [ds]
  (sort-by |(index-of ($ :type) link-types) (filter |(index-of ($ :type) link-types) ds)))

(defn status-json [s]
  (if (nil? s)
    {:text "󰤫 network" :tooltip "NetworkManager is not running" :class "daemon-down"}
    (let [ds (by-preference (s :devices))
          up (filter |(= "connected" ($ :state)) ds)
          pending (find |(index-of ($ :state) ["connecting" "prepare" "config" "ip-config" "ip-check" "secondaries" "need-auth"]) ds)
          r (or (s :radios) {})]
      (cond
        (not (empty? up))
        (let [primary (link s (first up))]
          {:text (string (primary :icon) " " (primary :text))
           :tooltip (string/join (map |((link s $) :tooltip) up) "\n")
           :class "connected"})
        pending
        {:text (string ((link s pending) :icon) " connecting")
         :tooltip (string "Connecting " (or (get pending :connection) (pending :device)) "…")
         :class "connecting"}
        (and (not (r :wifi)) (not (and (r :wwan-hw) (r :wwan))))
        {:text "󰀝 airplane" :tooltip "Radios off" :class "disconnected"}
        {:text "󰤮 offline" :tooltip "No connection" :class "disconnected"}))))

(defn saved-wifi? [s ssid]
  (some |(and (= ($ :type) "802-11-wireless") (= ($ :name) ssid)) (s :connections)))

(defn menu [s]
  (def items @[])
  (def r (or (s :radios) {}))
  (def ds (s :devices))
  (each d (filter |(= "ethernet" ($ :type)) ds)
    (def up (= "connected" (d :state)))
    (array/push items
                {:id (string "eth:" (d :device)) :key "󰈀" :kind "ethernet" :active up
                 :label (string "Ethernet " (d :device))
                 :description (cond
                                up (join "Connected" (d :connection) "Enter disconnects")
                                (= "unavailable" (d :state)) "Cable unplugged"
                                (join "Disconnected" "Enter connects"))
                 :args (unless (= "unavailable" (d :state)) [(if up "down" "up") (d :device)])}))
  (when-let [d (find |(= "gsm" ($ :type)) ds)]
    (def info (or (s :modem) {}))
    (def profile (or (find |(= ($ :name) "cellular") (s :connections))
                     (find |(= ($ :type) "gsm") (s :connections))))
    (def up (= "connected" (d :state)))
    (def problem (modem-problem info))
    (def signal (modem-signal info))
    (def locked (= "locked" (get info "modem.generic.state")))
    (array/push items
                {:id "gsm" :key (level cell-glyphs signal) :kind "cellular" :active up
                 :label (or (get info "modem.3gpp.operator-name") "Mobile broadband")
                 :description (cond
                                (not (r :wwan)) "Mobile radio off"
                                up (join "Connected" (technology info) (when signal (string signal "%")) "Enter disconnects")
                                problem problem
                                (nil? profile) "No cellular profile · use the connection editor"
                                (join (capitalize (or (get info "modem.generic.state") "unknown")) (technology info) (when signal (string signal "%")) "Enter connects"))
                 :args (when (and profile (r :wwan) (or up locked (nil? problem)))
                         [(if up "deactivate" "activate") (profile :name)])
                 :secret (when (and locked (not up)) "SIM PIN")}))
  (when (r :wwan-hw)
    (array/push items
                {:id "radio:wwan" :key "󰒢" :kind "radio" :active (r :wwan)
                 :label "Mobile radio"
                 :description (if (r :wwan) "On · Enter turns off" "Off · Enter turns on")
                 :args ["radio" "wwan" (if (r :wwan) "off" "on")]}))
  (when (r :wifi-hw)
    (array/push items
                {:id "radio:wifi" :key "󰖩" :kind "radio" :active (r :wifi)
                 :label "Wi-Fi radio"
                 :description (if (r :wifi) "On · Enter turns off" "Off · Enter turns on")
                 :args ["radio" "wifi" (if (r :wifi) "off" "on")]}))
  (each n (s :networks)
    (def secured (not (empty? (n :security))))
    (def enterprise (string/find "802.1X" (n :security)))
    (def saved (saved-wifi? s (n :ssid)))
    (array/push items
                {:id (string "wifi:" (n :ssid)) :key (level wifi-glyphs (n :signal)) :kind "wifi"
                 :active (n :in-use) :label (n :ssid)
                 :description (join (cond (n :in-use) "Connected" saved "Saved" (not secured) "Open" nil)
                                    (string (n :signal) "%")
                                    (when secured (n :security))
                                    (cond
                                      (n :in-use) "Enter disconnects"
                                      (and enterprise (not saved)) "Set up in the connection editor"))
                 :editor (and enterprise (not saved) (not (n :in-use)))
                 :args (cond
                         (n :in-use) ["down" (get (find |(= "wifi" ($ :type)) ds) :device)]
                         (and enterprise (not saved)) nil
                         ["wifi" (n :ssid) (n :security)])
                 :secret (when (and secured (not saved) (not enterprise) (not (n :in-use)))
                           (string "Password for " (n :ssid)))}))
  items)

(defn outcome [result ok-message]
  (if (zero? (result :status))
    {:ok true :message ok-message}
    {:ok false
     :message (let [text (string/trim (if (empty? (result :err)) (result :out) (result :err)))]
                (string/replace "Error: " "" (or (last (lines text)) "failed")))}))

(defn secret [] (let [v (os/getenv "NETWORK_SECRET")] (unless (empty? (or v "")) v)))

# A new secured network gets a profile first so its password reaches nmcli on
# stdin rather than in argv; a failed first connect drops the profile again so
# the next attempt asks for the password instead of reusing a wrong one.
(defn connect-wifi [ssid security]
  (if-let [password (secret)]
    (let [sae (and (string/find "WPA3" (or security "")) (not (string/find "WPA2" security)))
          added (run ["nmcli" "connection" "add" "type" "wifi" "con-name" ssid "ssid" ssid
                      "wifi-sec.key-mgmt" (if sae "sae" "wpa-psk")])]
      (if (not (zero? (added :status)))
        (outcome added "")
        (let [result (run ["nmcli" "--wait" "45" "connection" "up" "id" ssid "passwd-file" "/dev/stdin"]
                          (string "802-11-wireless-security.psk:" password "\n"))]
          (unless (zero? (result :status))
            (run ["nmcli" "connection" "delete" "id" ssid]))
          (outcome result (string "Connected to " ssid)))))
    (outcome (run ["nmcli" "--wait" "45" "device" "wifi" "connect" ssid]) (string "Connected to " ssid))))

(defn activate [name]
  (outcome (if-let [pin (secret)]
             (run ["nmcli" "--wait" "60" "connection" "up" "id" name "passwd-file" "/dev/stdin"]
                  (string "gsm.pin:" pin "\n"))
             (run ["nmcli" "--wait" "60" "connection" "up" "id" name]))
           (string "Connected " name)))

(defn action [args]
  (match args
    ["up" device] (outcome (run ["nmcli" "--wait" "30" "device" "connect" device]) (string device " connected"))
    ["down" device] (outcome (run ["nmcli" "device" "disconnect" device]) (string device " disconnected"))
    ["activate" name] (activate name)
    ["deactivate" name] (outcome (run ["nmcli" "connection" "down" "id" name]) (string name " disconnected"))
    ["radio" kind state] (outcome (run ["nmcli" "radio" kind state])
                                  (string (if (= kind "wifi") "Wi-Fi" "Mobile") " radio " state))
    # Tuple patterns match prefixes, so the longer form goes first.
    ["wifi" ssid security] (connect-wifi ssid security)
    ["wifi" ssid] (connect-wifi ssid nil)
    _ nil))

(defn selftest []
  (assert (deep= @["a:b" "" "c\\d"] (fields `a\:b::c\\d`)))
  (assert (deep= @["The Promised WAN (5GHz)" "802-11-wireless"]
                 (fields "The Promised WAN (5GHz):802-11-wireless")))
  (def devices-out "enp5s0:ethernet:connected:Wired connection 1\nwlo1:wifi:connecting (getting IP configuration):Home\ncdc-wdm0:gsm:disconnected:\nlo:loopback:connected (externally):lo")
  (def ds (devices devices-out))
  (assert (= "connecting" ((get ds 1) :state)))
  (assert (deep= @["ethernet" "wifi" "gsm"] (map |($ :type) (by-preference ds))))
  (def nets (networks "*:Home:WPA2:70\n:Home:WPA2:90\n:Cafe::40\n:Cafe::55\n::WPA2:99\n:Work:WPA2 802.1X:80"))
  (assert (deep= @["Home" "Work" "Cafe"] (map |($ :ssid) nets)))
  (assert (= 55 ((last nets) :signal)))
  (def info (modem "modem.generic.state                  : connected\nmodem.generic.power-state : on\nmodem.generic.signal-quality.value : 72\nmodem.generic.access-technologies.length : 2\nmodem.generic.access-technologies.value[1] : lte\nmodem.generic.access-technologies.value[2] : 5gnr\nmodem.3gpp.operator-name : Mint\nmodem.generic.sim : /org/freedesktop/ModemManager1/SIM/0\nmodem.generic.state-failed-reason : --"))
  (assert (= "5G" (technology info)))
  (assert (= 72 (modem-signal info)))
  (assert (nil? (get info "modem.generic.state-failed-reason")))
  (assert (= "/org/freedesktop/ModemManager1/SIM/0" (get info "modem.generic.sim")))
  (assert (= "No SIM card" (modem-problem {"modem.generic.state" "failed" "modem.generic.state-failed-reason" "sim-missing"})))
  (assert (= "󰤯" (level wifi-glyphs 0)))
  (assert (= "󰤨" (level wifi-glyphs 100)))
  (assert (= "󰢾" (level cell-glyphs 100)))
  (assert (= "123456789012345…" (short "12345678901234567890")))
  (def radios-on (radios "enabled:enabled:enabled:enabled"))
  (def base {:radios radios-on :connections @[{:name "Home" :type "802-11-wireless"} {:name "cellular" :type "gsm"}]
             :networks nets :modem info})
  (def wired (status-json (merge base {:devices (devices "enp5s0:ethernet:connected:Wired connection 1\nwlo1:wifi:connected:Home")})))
  (assert (= "󰈀 wired" (wired :text)))
  (assert (= "Ethernet · enp5s0 · Wired connection 1\nWi-Fi · Home · 70%" (wired :tooltip)))
  (def wifi (status-json (merge base {:devices (devices "wlo1:wifi:connected:Home")})))
  (assert (= "󰤥 Home" (wifi :text)))
  (def cell (status-json (merge base {:devices (devices "cdc-wdm0:gsm:connected:cellular")})))
  (assert (= "󰢽 5G" (cell :text)))
  (assert (= "Mobile · Mint · 5G · 72%" (cell :tooltip)))
  (assert (= "connecting" ((status-json (merge base {:devices (devices "wlo1:wifi:connecting (getting IP configuration):Home")})) :class)))
  (assert (= "󰀝 airplane" ((status-json (merge base {:devices @[] :radios (radios "enabled:disabled:missing:enabled")})) :text)))
  (assert (= "󰤮 offline" ((status-json (merge base {:devices @[]})) :text)))
  (assert (= "daemon-down" ((status-json nil) :class)))
  (def items (menu (merge base {:devices (devices "enp5s0:ethernet:unavailable:\nwlo1:wifi:connected:Home\ncdc-wdm0:gsm:disconnected:")})))
  (def by-id (tabseq [i :in items] (i :id) i))
  (assert (nil? ((by-id "eth:enp5s0") :args)))
  (assert (deep= ["activate" "cellular"] ((by-id "gsm") :args)))
  (assert (deep= ["down" "wlo1"] ((by-id "wifi:Home") :args)))
  (assert (deep= ["wifi" "Cafe" ""] ((by-id "wifi:Cafe") :args)))
  (assert (nil? ((by-id "wifi:Cafe") :secret)))
  (assert ((by-id "wifi:Work") :editor))
  (assert (nil? ((by-id "wifi:Work") :args)))
  (def stranger (menu (merge base {:devices (devices "wlo1:wifi:disconnected:")
                                   :networks (networks ":Neighbour:WPA3:50")})))
  (assert (= "Password for Neighbour" ((last stranger) :secret)))
  (def locked (menu (merge base {:devices (devices "cdc-wdm0:gsm:disconnected:")
                                 :modem {"modem.generic.state" "locked"}})))
  (assert (= "SIM PIN" ((first locked) :secret)))
  (assert (deep= ["activate" "cellular"] ((first locked) :args)))
  (def calls @[])
  (with-dyns [:network-exec (fn [args input] (array/push calls [args input])
                              (if (= "up" (get args 4))
                                {:status 4 :out "" :err "Error: Connection activation failed: Secrets were required, but not provided."}
                                {:status 0 :out "" :err ""}))]
    (os/setenv "NETWORK_SECRET" "hunter2")
    (def result (action ["wifi" "Neighbour" "WPA3"]))
    (os/setenv "NETWORK_SECRET" nil)
    (assert (not (result :ok)))
    (assert (= "Connection activation failed: Secrets were required, but not provided." (result :message)))
    (assert (= "sae" (last (first (get calls 0)))))
    (assert (= "802-11-wireless-security.psk:hunter2\n" (get-in calls [1 1])))
    (assert (not (find |(= $ "hunter2") (get-in calls [1 0]))))
    (assert (deep= ["nmcli" "connection" "delete" "id" "Neighbour"] (get-in calls [2 0]))))
  (assert (nil? (action ["bogus"])))
  (print "ok"))

(defn main [script & args]
  (case (first args)
    nil (print (json/encode (status-json (snapshot))))
    "list" (if-let [s (snapshot (= "--rescan" (get args 1)))]
             (print (json/encode (menu s)))
             (do (eprint "network: NetworkManager is not running") (os/exit 1)))
    "selftest" (selftest)
    (if-let [result (action args)]
      (print (json/encode result))
      (do
        (eprint "usage: network [list [--rescan] | up|down DEVICE | activate|deactivate NAME | radio wifi|wwan on|off | wifi SSID [SECURITY]]")
        (os/exit 2)))))
