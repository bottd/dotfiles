;; Even column widths on landscape workspaces — niri has no native
;; auto-rebalance (columns keep whatever width they opened at). One column
;; fills the screen; a 2nd splits to ½; a 3rd (and beyond) holds at ⅓ so the
;; row overflows and scrolls. Sibling of niri-vert-scroll.clj, which does the
;; same even-split for *height* on portrait outputs.

(require '[cheshire.core :as json]
         '[babashka.process :as p]
         '[clojure.java.io :as io])

(def max-visible 3)

;; nil on failure — niri msg errors transiently; a throw would kill the daemon.
(defn niri-json [& args]
  (try (-> (apply p/shell {:out :string} "niri" "msg" "--json" args)
           :out (json/parse-string true))
       (catch Exception _ nil)))

(defn niri-action [& args]
  (try (apply p/shell {:out :string :err :string} "niri" "msg" "action" args)
       (catch Exception _ nil)))

(defn landscape-ws-ids []
  (let [landscape (->> (niri-json "outputs") vals
                       (filter #(>= (get-in % [:logical :width] 0)
                                    (get-in % [:logical :height] 0)))
                       (map :name) set)]
    (->> (niri-json "workspaces")
         (filter #(contains? landscape (:output %)))
         (map :id) set)))

(defn column-of [w] (get-in w [:layout :pos_in_scrolling_layout 0]))

;; Rebalance any workspace whose column count changed since we last saw it.
;; Keyed on count so our own set-window-width (which re-fires
;; WindowOpenedOrChanged) is a no-op — it never changes the count, so no loop.
;; set-window-width takes --id, so we resize each column by its first window's
;; id without focusing it (no stolen focus / warped mouse). One windows fetch
;; covers every workspace.
(defn reconcile-all [ws-ids counts]
  (let [by-ws (->> (niri-json "windows")
                   (filter #(and (contains? ws-ids (:workspace_id %))
                                 (not (:is_floating %))))
                   (group-by :workspace_id))]
    (reduce
     (fn [acc ws-id]
       (let [cols (vals (group-by column-of (get by-ws ws-id [])))
             n    (count cols)]
         (if (= n (get counts ws-id))
           acc
           (do (when (pos? n)
                 (let [pct (str (quot 100 (min n max-visible)) "%")]
                   (doseq [col cols]
                     (niri-action "set-window-width" pct "--id"
                                  (str (:id (first col)))))))
               (assoc acc ws-id n)))))
     counts
     ws-ids)))

(defn parse-line [s]
  (try (json/parse-string s true) (catch Exception _ nil)))

(defn -main []
  (let [proc (p/process ["niri" "msg" "--json" "event-stream"] {:out :stream})]
    (with-open [rdr (io/reader (:out proc))]
      (loop [ws-ids (landscape-ws-ids)
             counts {}]
        (when-let [line (.readLine rdr)]
          (let [[ev-type _] (some-> line parse-line first)]
            (case ev-type
              :WorkspacesChanged     (recur (landscape-ws-ids) counts)
              :WindowClosed          (recur ws-ids (reconcile-all ws-ids counts))
              :WindowOpenedOrChanged (recur ws-ids (reconcile-all ws-ids counts))
              (recur ws-ids counts))))))))

(-main)
