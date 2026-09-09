(import spork/json)
(import spork/sh)

(defn status []
  (try (json/decode (sh/exec-slurp "mullvad" "status" "-j") true true)
    ([_] nil)))

(defn place [& parts]
  (def present (filter (fn [s] (and s (not (empty? (string/trim s))))) parts))
  (if (empty? present) "?" (string/join present ", ")))

(defn waybar-json [s]
  (def state (get s :state))
  (def {:hostname hostname :city city :country country} (or (get-in s [:details :location]) {}))
  (cond
    (nil? s) {:text "󰦞" :tooltip "mullvad: daemon down"}
    (= state "connected")
    {:text (string "󰦝 " (or hostname city "on"))
     :tooltip (string "mullvad: connected · " (place country))
     :class "connected"}
    {:text (string "󰦞 " (if (= state "disconnected") "off" state))
     :tooltip (string "mullvad: " state " · " (place city country))
     :class (if (nil? state) :null state)}))

(defn toggle []
  (sh/exec-fail "mullvad" (if (= "connected" (get (status) :state)) "disconnect" "connect")))

(defn login []
  (def account (string/trim (sh/exec-slurp "rbw" "get" "mullvad")))
  (sh/exec-fail "mullvad" "account" "login" account))

(defn selftest []
  (assert (= "connected" (get (waybar-json {:state "connected"
                                            :details {:location {:hostname "se-mma-wg-001"}}}) :class)))
  (assert (string/has-suffix? "off" (get (waybar-json {:state "disconnected"}) :text)))
  (assert (string/find "daemon down" (get (waybar-json nil) :tooltip)))
  (assert (= "mullvad: disconnected · United States"
             (get (waybar-json (json/decode `{"state":"disconnected","details":{"location":{"city":null,"country":"United States"}}}` true true)) :tooltip)))
  (assert (string/has-suffix? "· ?" (get (waybar-json {:state "disconnected"}) :tooltip)))
  (assert (= "?" (place nil "" " \t\r\n")))
  (assert (= "Malmo, Sweden" (place "Malmo" nil "Sweden")))
  (assert (deep= {:text "󰦝 on" :tooltip "mullvad: connected · ?" :class "connected"}
                 (waybar-json (json/decode `{"state":"connected","details":{"location":{"hostname":null,"city":null}}}` true true))))
  (assert (deep= {:text "󰦞 connecting" :tooltip "mullvad: connecting · Sweden" :class "connecting"}
                 (waybar-json {:state "connecting" :details {:location {:country "Sweden"}}})))
  (assert (= :null (get (json/decode (json/encode (waybar-json {})) true) :class)))
  (print "ok"))

(defn main [script & args]
  (case (first args)
    nil (print (json/encode (waybar-json (status))))
    "toggle" (toggle)
    "login" (login)
    "selftest" (selftest)
    (do
      (eprint "usage: waybar-mullvad [toggle|login]")
      (os/exit 2))))
