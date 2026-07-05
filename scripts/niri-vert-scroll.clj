;; One vertical, scrolling column on a portrait monitor — niri has no native
;; vertical layout (YaLTeR/niri#1071). Pulls each window into a single column,
;; then even-splits height up to :max-visible (full, ½, ⅓ …) and holds at
;; 1/:max-visible beyond that so the column overflows and scrolls.

(require '[cheshire.core :as json]
         '[babashka.process :as p]
         '[clojure.java.io :as io])

(def config {:max-visible 3})

;; nil on failure — niri msg errors transiently; a throw would kill the daemon.
(defn niri-json [& args]
  (try (-> (apply p/shell {:out :string} "niri" "msg" "--json" args)
           :out (json/parse-string true))
       (catch Exception _ nil)))

(defn niri-action [& args]
  (try (apply p/shell {:out :string :err :string} "niri" "msg" "action" args)
       (catch Exception _ nil)))

(defn portrait-ws-ids []
  (let [portrait (->> (niri-json "outputs") vals
                      (filter #(< (get-in % [:logical :width] 0)
                                  (get-in % [:logical :height] 0)))
                      (map :name) set)]
    (->> (niri-json "workspaces")
         (filter #(contains? portrait (:output %)))
         (map :id) set)))

(defn column-of [w] (get-in w [:layout :pos_in_scrolling_layout 0]))

(defn apply-heights! [ws-id]
  (let [wins     (filter #(= (:workspace_id %) ws-id) (niri-json "windows"))
        maxv     (:max-visible config)
        overflow (> (count wins) maxv)
        pct      (str (quot 100 maxv) "%")]
    (doseq [w wins]
      (if overflow
        (niri-action "set-window-height" pct "--id" (str (:id w)))
        (niri-action "reset-window-height" "--id" (str (:id w)))))))

;; The pull re-fires an event, so multi-column layouts converge one step a time.
(defn consolidate! [w]
  (when (> (or (column-of w) 1) 1)
    (niri-action "consume-or-expel-window-left" "--id" (str (:id w)))
    (apply-heights! (:workspace_id w))))

;; The typed niri config can't set a per-output default-column-width, so we
;; widen the portrait column to full width here. set-column-width has no --id;
;; it acts on the *focused* column, so only fire it when this window is focused
;; (else we'd resize whatever column is focused on the landscape monitor).
;; ponytail: a background-opened portrait window stays at default width until
;; it's focused-and-changed — fine, the common open-here case is focused.
(defn widen! [w]
  (when (:is_focused w)
    (niri-action "set-column-width" "100%")))

(defn parse-line [s]
  (try (json/parse-string s true) (catch Exception _ nil)))

(defn -main []
  (let [proc (p/process ["niri" "msg" "--json" "event-stream"] {:out :stream})]
    (with-open [rdr (io/reader (:out proc))]
      (loop [ws-ids (portrait-ws-ids)]
        (when-let [line (.readLine rdr)]
          (let [[ev-type payload] (some-> line parse-line first)]
            (case ev-type
              :WorkspacesChanged     (recur (portrait-ws-ids))
              :WindowClosed          (do (run! apply-heights! ws-ids) (recur ws-ids))
              :WindowOpenedOrChanged (let [w (:window payload)]
                                       (when (contains? ws-ids (:workspace_id w))
                                         (consolidate! w)
                                         (widen! w))
                                       (recur ws-ids))
              (recur ws-ids))))))))

(-main)
