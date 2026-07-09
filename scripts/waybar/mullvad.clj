;; Waybar module and control for Mullvad. The daemon is enabled system-wide
;; (system/nixOS/mullvad.nix), so drive its CLI rather than running the Electron
;; GUI just for a tray icon.
;;
;;   waybar-mullvad          ;; one JSON line for waybar's custom module
;;   waybar-mullvad toggle   ;; connect if down, disconnect if up
;;   waybar-mullvad login    ;; account number from the Bitwarden item "mullvad";
;;                           ;; needs an unlocked vault: BW_SESSION=$(bw unlock --raw)

(require '[cheshire.core :as json]
         '[babashka.process :as p]
         '[clojure.string :as str])

;; nil rather than a throw: the daemon is often down right after login, and
;; waybar would render an empty module instead of the "off" icon.
(defn status []
  (try (-> (p/shell {:out :string} "mullvad" "status" "-j")
           :out (json/parse-string true))
       (catch Exception _ nil)))

;; Mullvad reports `city: null` whenever it only geolocates to a country, so
;; join the parts that exist rather than rendering "?, United States".
(defn place [& parts]
  (or (not-empty (str/join ", " (remove str/blank? parts))) "?"))

(defn waybar-json [{:keys [state details] :as s}]
  (let [{:keys [hostname city country]} (:location details)]
    (cond
      (nil? s)              {:text "󰦞" :tooltip "mullvad: daemon down"}
      (= state "connected") {:text    (str "󰦝 " (or hostname city "on"))
                             :tooltip (str "mullvad: connected · " (place country))
                             :class   "connected"}
      :else                 {:text    (str "󰦞 " (if (= state "disconnected") "off" state))
                             :tooltip (str "mullvad: " state " · " (place city country))
                             :class   state})))

(defn toggle []
  (if (= "connected" (:state (status)))
    (p/shell "mullvad" "disconnect")
    (p/shell "mullvad" "connect")))

;; bw prints its own diagnostics (locked vault, no such item) and exits nonzero,
;; so let p/shell's throw carry that out rather than reformatting it.
(defn login []
  (let [account (-> (p/shell {:out :string} "bw" "get" "password" "mullvad") :out str/trim)]
    (p/shell "mullvad" "account" "login" account)))

(defn selftest []
  (assert (= "connected" (:class (waybar-json {:state "connected"
                                               :details {:location {:hostname "se-mma-wg-001"}}}))))
  (assert (str/ends-with? (:text (waybar-json {:state "disconnected"})) "off"))
  (assert (str/includes? (:tooltip (waybar-json nil)) "daemon down"))
  (assert (= "mullvad: disconnected · United States"
             (:tooltip (waybar-json {:state "disconnected"
                                     :details {:location {:city nil :country "United States"}}}))))
  (assert (str/ends-with? (:tooltip (waybar-json {:state "disconnected"})) "· ?"))
  (println "ok"))

(case (first *command-line-args*)
  nil        (println (json/generate-string (waybar-json (status))))
  "toggle"   (toggle)
  "login"    (login)
  "selftest" (selftest)
  (binding [*out* *err*]
    (println "usage: waybar-mullvad [toggle|login]")
    (System/exit 2)))
