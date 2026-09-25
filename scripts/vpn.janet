(import spork/json)
(import spork/sh)

(defn status []
  (try (json/decode (sh/exec-slurp "tailscale" "status" "--json") true true)
    ([_] nil)))

(defn place [& parts]
  (def present (filter (fn [s] (and s (not (empty? (string/trim s))))) parts))
  (if (empty? present) "?" (string/join present ", ")))

(defn exit-peer [s]
  (find |(get $ :ExitNode) (values (or (get s :Peer) {}))))

(defn status-json [s]
  (def backend (get s :BackendState))
  (def exit (get s :ExitNodeStatus))
  (def peer (exit-peer s))
  (def {:City city :Country country} (or (get peer :Location) {}))
  (cond
    (nil? s) {:text "󰦞" :tooltip "tailscale: daemon down"}
    (not= backend "Running")
    {:text "󰦞 off"
     :tooltip (string "tailscale: " (string/ascii-lower (or backend "unknown")))
     :class "disconnected"}
    (nil? exit) {:text "󰦞 off" :tooltip "vpn: no exit node" :class "disconnected"}
    (not (get exit :Online))
    {:text "󰦞 offline"
     :tooltip (string "vpn: exit node offline · " (place (get peer :HostName)))
     :class "failed"}
    {:text (string "󰦝 " (or (get peer :HostName) "on"))
     :tooltip (string "vpn: connected · " (place city country))
     :class "connected"}))

(defn toggle []
  (sh/exec-fail "tailscale" "set"
                (string "--exit-node=" (if (get (status) :ExitNodeStatus) "" "auto:any"))))

(defn selftest []
  (def peers {:a {:HostName "se-mma-wg-001" :ExitNode true
                  :Location {:City "Malmö" :Country "Sweden"}}
              :b {:HostName "loge"}})
  (def running {:BackendState "Running" :Peer peers})
  (assert (= "connected" (get (status-json (merge running {:ExitNodeStatus {:Online true}})) :class)))
  (assert (= "󰦝 se-mma-wg-001" (get (status-json (merge running {:ExitNodeStatus {:Online true}})) :text)))
  (assert (= "vpn: connected · Malmö, Sweden"
             (get (status-json (merge running {:ExitNodeStatus {:Online true}})) :tooltip)))
  (assert (= "failed" (get (status-json (merge running {:ExitNodeStatus {:Online false}})) :class)))
  (assert (= "disconnected" (get (status-json running) :class)))
  (assert (= "tailscale: stopped" (get (status-json {:BackendState "Stopped"}) :tooltip)))
  (assert (string/find "daemon down" (get (status-json nil) :tooltip)))
  (assert (= "vpn: connected · ?"
             (get (status-json (json/decode `{"BackendState":"Running","ExitNodeStatus":{"Online":true},"Peer":{"x":{"ExitNode":true,"HostName":null}}}` true true)) :tooltip)))
  (assert (= "?" (place nil "" " \t\r\n")))
  (print "ok"))

(defn main [script & args]
  (case (first args)
    nil (print (json/encode (status-json (status))))
    "toggle" (toggle)
    "selftest" (selftest)
    (do
      (eprint "usage: vpn [toggle]")
      (os/exit 2))))
