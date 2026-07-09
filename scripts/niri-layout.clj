;; Orientation-aware layout daemon — niri keeps each column at whatever size it
;; opened at, and has no native vertical layout (YaLTeR/niri#1071).
;;
;; Landscape workspaces: even column *widths*, 1 / min(n, max-visible) — one
;; column fills the screen, two split ½, three+ hold at ⅓ so the row overflows
;; and scrolls.
;;
;; Portrait workspaces: one full-width scrolling column — each window is pulled
;; into the column, heights even-split up to max-visible and held at
;; 1/max-visible beyond that so the column overflows and scrolls.

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

;; {:landscape #{ws-id …} :portrait #{ws-id …}}, split by output aspect.
(defn ws-ids-by-orientation []
  (let [outputs   (vals (niri-json "outputs"))
        names     (fn [pred] (->> outputs (filter pred) (map :name) set))
        wide?     #(>= (get-in % [:logical :width] 0)
                       (get-in % [:logical :height] 0))
        landscape (names wide?)
        portrait  (names (complement wide?))
        wss       (niri-json "workspaces")
        ids       (fn [outs] (->> wss
                                  (filter #(contains? outs (:output %)))
                                  (map :id) set))]
    {:landscape (ids landscape) :portrait (ids portrait)}))

(defn column-of [w] (get-in w [:layout :pos_in_scrolling_layout 0]))

;; --- landscape: even widths -------------------------------------------------

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

;; --- portrait: single column, even heights ----------------------------------

(defn apply-heights! [ws-id]
  (let [wins     (filter #(= (:workspace_id %) ws-id) (niri-json "windows"))
        overflow (> (count wins) max-visible)
        pct      (str (quot 100 max-visible) "%")]
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

;; --- event loop ---------------------------------------------------------------

(defn parse-line [s]
  (try (json/parse-string s true) (catch Exception _ nil)))

(defn -main []
  (let [proc (p/process ["niri" "msg" "--json" "event-stream"] {:out :stream})]
    (with-open [rdr (io/reader (:out proc))]
      (loop [{:keys [landscape portrait] :as ws} (ws-ids-by-orientation)
             counts {}]
        (when-let [line (.readLine rdr)]
          (let [[ev-type payload] (some-> line parse-line first)]
            (case ev-type
              :WorkspacesChanged
              (recur (ws-ids-by-orientation) counts)

              :WindowClosed
              (do (run! apply-heights! portrait)
                  (recur ws (reconcile-all landscape counts)))

              :WindowOpenedOrChanged
              (let [w (:window payload)]
                (when (contains? portrait (:workspace_id w))
                  (consolidate! w)
                  (widen! w))
                (recur ws (reconcile-all landscape counts)))

              (recur ws counts))))))))

(-main)
