;; Waybar module and control for Mullvad. The daemon is enabled system-wide
;; (system/nixOS/mullvad.nix), so drive its CLI rather than running the Electron
;; GUI just for a tray icon.
;;
;;   mullvad-ctl waybar    ;; one JSON line for waybar's custom module
;;   mullvad-ctl toggle    ;; connect if down, disconnect if up
;;   mullvad-ctl login     ;; account number from the Bitwarden item "mullvad";
;;                         ;; needs an unlocked vault: BW_SESSION=$(bw unlock --raw)

(require '[cheshire.core :as json]
         '[babashka.process :as p]
         '[clojure.string :as str])

;; nil on failure — the daemon is often down at login, and a throw would leave
;; waybar with an empty module instead of an "off" icon.
(defn sh [& args]
  (try (-> (apply p/shell {:out :string} args) :out str/trim)
       (catch Exception _ nil)))

(defn status [] (some-> (sh "mullvad" "status" "-j") (json/parse-string true)))

(defn waybar-json [s]
  (if-let [{:keys [state details]} s]
    (let [{:keys [hostname city country]} (:location details)]
      (if (= state "connected")
        {:text    (str "󰦝 " (or hostname city "on"))
         :tooltip (str "mullvad: connected · " (or country "?"))
         :class   "connected"}
        {:text    (str "󰦞 " (if (= state "disconnected") "off" state))
         :tooltip (str "mullvad: " state " · " (or city "?") ", " (or country "?"))
         :class   state}))
    {:text "󰦞" :tooltip "mullvad: daemon down"}))

(defn login []
  (let [account (sh "bw" "get" "password" "mullvad")]
    (when (str/blank? account)
      (binding [*out* *err*]
        (println "bw returned no account number; is the vault unlocked?"))
      (System/exit 1))
    (p/shell "mullvad" "account" "login" account)))

(defn toggle []
  (if (= "connected" (:state (status)))
    (p/shell "mullvad" "disconnect")
    (p/shell "mullvad" "connect")))

(defn selftest []
  (assert (= "connected" (:class (waybar-json {:state "connected"
                                               :details {:location {:hostname "se-mma-wg-001"}}}))))
  (assert (str/ends-with? (:text (waybar-json {:state "disconnected"})) "off"))
  (assert (str/includes? (:tooltip (waybar-json nil)) "daemon down"))
  (println "ok"))

(case (first *command-line-args*)
  "waybar"   (println (json/generate-string (waybar-json (status))))
  "toggle"   (toggle)
  "login"    (login)
  "selftest" (selftest)
  (binding [*out* *err*]
    (println "usage: mullvad-ctl waybar|toggle|login")
    (System/exit 2)))
