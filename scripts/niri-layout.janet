# Orientation-aware layout daemon: landscape columns split widths up to three
# visible columns; portrait windows share one full-width scrolling column, with
# heights split up to three visible windows.

(import spork/json)
(import spork/sh)
(import spork/stream)

(def max-visible 3)

# Niri queries fail transiently. Keep stderr visible, but do not kill the daemon.
(defn niri-json [& args]
  (try (json/decode (sh/exec-slurp "niri" "msg" "--json" ;args) true true)
    ([_] nil)))

(defn niri-action [& args]
  (try
    (let [result (sh/exec-slurp-all "niri" "msg" "action" ;args)]
      (when (= 0 (result :status)) result))
    ([_] nil)))

(defn wide? [output]
  (>= (get-in output [:logical :width] 0)
      (get-in output [:logical :height] 0)))

(defn ws-ids-by-orientation []
  (def landscape @{})
  (def portrait @{})
  (each output (values (or (niri-json "outputs") {}))
    (put (if (wide? output) landscape portrait) (output :name) true))
  (def ids {:landscape @{} :portrait @{}})
  (each ws (or (niri-json "workspaces") [])
    (each [orientation outputs] [[:landscape landscape] [:portrait portrait]]
      (when (get outputs (ws :output))
        (put (ids orientation) (ws :id) true))))
  ids)

(defn column-of [w]
  (get-in w [:layout :pos_in_scrolling_layout 0]))

(defn columns [wins]
  # Unlike Clojure, Janet tables cannot group under a nil key.
  (values (group-by (fn [w] (or (column-of w) :unpositioned)) wins)))

# Cache by column count so our own resize events cannot trigger a resize loop.
# Resize each column by its first window's ID, without changing focus.
(defn reconcile-all [ws-ids counts]
  (def by-ws
    (group-by (fn [w] (w :workspace_id))
              (filter (fn [w] (and (get ws-ids (w :workspace_id)) (not (w :is_floating))))
                      (or (niri-json "windows") []))))
  (def updated (table/clone counts))
  (each ws-id (keys ws-ids)
    (def cols (columns (get by-ws ws-id [])))
    (def n (length cols))
    (unless (= n (get counts ws-id))
      (when (> n 0)
        (def pct (string (div 100 (min n max-visible)) "%"))
        (each col cols
          (niri-action "set-window-width" pct "--id" (string (get (first col) :id)))))
      # Retain the original behavior: cache counts even when a resize fails.
      (put updated ws-id n)))
  updated)

(defn apply-heights! [ws-id]
  (def wins (filter (fn [w] (= (w :workspace_id) ws-id)) (or (niri-json "windows") [])))
  (def overflow (> (length wins) max-visible))
  (def pct (string (div 100 max-visible) "%"))
  (each w wins
    (if overflow
      (niri-action "set-window-height" pct "--id" (string (w :id)))
      (niri-action "reset-window-height" "--id" (string (w :id))))))

# Move one step per handled window event; layout-only events remain ignored.
(defn consolidate! [w]
  (when (> (or (column-of w) 1) 1)
    (niri-action "consume-or-expel-window-left" "--id" (string (get w :id)))
    (apply-heights! (get w :workspace_id))))

(defn widen! [w]
  (when (get w :is_focused)
    (niri-action "set-column-width" "100%")))

(defn parse-line [text]
  (try (json/decode text true true) ([_] nil)))

(defn run []
  (with [proc (os/spawn ["niri" "msg" "--json" "event-stream"] :p {:out :pipe})]
    (try
      (do
        (var ws (ws-ids-by-orientation))
        (var counts @{})
        (each line (stream/lines (proc :out))
          (def event (or (parse-line line) {}))
          (def ev-type (next event))
          (def payload (get event ev-type))
          (case ev-type
            :WorkspacesChanged
            (set ws (ws-ids-by-orientation))
            :WindowClosed
            (do
              (each ws-id (keys (ws :portrait)) (apply-heights! ws-id))
              (set counts (reconcile-all (ws :landscape) counts)))
            :WindowOpenedOrChanged
            (do
              (def w (get payload :window))
              (when (get (ws :portrait) (get w :workspace_id))
                (consolidate! w)
                (widen! w))
              (set counts (reconcile-all (ws :landscape) counts)))
            # WindowsChanged and WindowLayoutsChanged remain ignored.
            nil))
        # Drain stdout before waiting; stderr is inherited, not piped.
        (os/proc-wait proc)
        nil)
      ([err]
        # A handler/read failure must not leave a live event-stream child behind.
        (protect (os/proc-kill proc))
        (error err)))))

(defn selftest []
  (assert (= nil (parse-line "not json")))
  (assert (= nil (parse-line "null")))
  (assert (= :WindowClosed (next (parse-line `{"WindowClosed":{"id":12}}`))))
  (assert (deep= {:WindowOpenedOrChanged {:window {:id 12}}}
                 (freeze (parse-line `{"WindowOpenedOrChanged":{"window":{"id":12,"layout":null}}}`))))
  (assert (wide? {:logical {:width 1920 :height 1080}}))
  (assert (wide? {:logical {:width 1080 :height 1080}}))
  (assert (wide? {}))
  (assert (not (wide? {:logical {:width 1080 :height 1920}})))
  (assert (= 2 (column-of {:layout {:pos_in_scrolling_layout [2 1]}})))
  (assert (= 0 (column-of {:layout {:pos_in_scrolling_layout [0 1]}})))
  (assert (= nil (column-of (parse-line `{"layout":{"pos_in_scrolling_layout":null}}`))))
  (assert (= nil (column-of nil)))
  (assert (empty? (columns [])))
  (def cols (columns [{:id 1 :layout {:pos_in_scrolling_layout [1 1]}}
                      {:id 2 :layout {:pos_in_scrolling_layout [1 2]}}
                      {:id 3 :layout {:pos_in_scrolling_layout [2 1]}}
                      {:id 4} {:id 5}]))
  (assert (= 3 (length cols)))
  (assert (deep= [1 2 2] (freeze (sort (map length cols)))))
  (assert (deep= [1 3 4] (freeze (sort (map (fn [col] (get (first col) :id)) cols)))))
  (print "ok"))

(defn main [script & args]
  (if (= "selftest" (first args)) (selftest) (run)))
