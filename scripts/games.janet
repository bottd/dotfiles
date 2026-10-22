(import spork/sh)
(import spork/path)
(import spork/json)

# Quickshell passes the store path; a shell falls back to PATH.
(def aurelia (os/getenv "AURELIA" "aurelia"))

(defn xdg-home [variable fallback]
  (def value (os/getenv variable ""))
  (if (empty? value) (path/join (os/getenv "HOME") fallback) value))

(def icon-file (peg/compile ~(* (repeat 40 (range "09" "af")) ".jpg" -1)))

# Steam caches each game's 32px icon as <sha1>.jpg beside its library art.
# The hash is the store's, so the file can only be found by listing.
(defn cache-icon [cache app-id]
  (def dir (path/join cache (string app-id)))
  (when (= :directory (os/stat dir :mode))
    (when-let [name (find |(peg/match icon-file $) (sorted (os/dir dir)))]
      (path/join dir name))))

(defn enrich [library cache]
  (map |(merge $ {:icon (cache-icon cache (get $ :app_id))})
       (filter |(get $ :is_installed) library)))

(defn list-games []
  (def library (json/decode (sh/exec-slurp aurelia "--json" "list" "--installed") true true))
  (def cache (path/join (xdg-home "XDG_DATA_HOME" ".local/share") "Steam/appcache/librarycache"))
  (print (json/encode (enrich library cache))))

(def ansi (peg/compile ~(* "\e[" (any (set "0123456789;")) (range "@~"))))

# aurelia logs through tracing; its last line is the reason it gave up.
(defn last-line [text]
  (def lines (map string/trim (string/split "\n" (peg/replace-all ansi "" text))))
  (last (filter |(not (empty? $)) lines)))

# A quick non-zero exit never reached the game; a late one is the game itself.
(defn failure-summary [name elapsed]
  (if (< elapsed 30) (string name " didn't start") (string name " exited with an error")))

(defn notify [& args]
  (string/trim (sh/exec-slurp "notify-send" "--app-name=Games" ;args)))

(defn play [name app-id & flags]
  (def icon (string "--icon=steam_icon_" app-id))
  (def id (protect (notify "--print-id" icon (string "Starting " name))))
  (def started (os/time))
  (def tail @"")
  (def code
    (with [proc (os/spawn [aurelia "play" app-id ;flags] :p {:err :pipe})]
      # Tee stderr: the journal keeps all of it, the notification the tail.
      (forever
        (def chunk (ev/read (proc :err) 4096))
        (unless chunk (break))
        (file/write stderr chunk)
        (file/flush stderr)
        (buffer/push tail chunk)
        (when (> (length tail) 16384)
          (def kept (buffer/slice tail -8193))
          (buffer/clear tail)
          (buffer/push tail kept)))
      (os/proc-wait proc)))
  (unless (zero? code)
    (protect
      (notify ;(if (and (first id) (not (empty? (get id 1)))) [(string "--replace-id=" (get id 1))] [])
              "--urgency=critical" icon
              (failure-summary name (- (os/time) started))
              (or (last-line (string tail)) (string "aurelia exited with code " code)))))
  (os/exit code))

(defn selftest []
  (assert (= "ERROR no such app" (last-line "\e[2mINFO\e[0m starting\n\e[31mERROR\e[0m no such app\n\n")))
  (assert (nil? (last-line "")))
  (assert (= "Deadlock didn't start" (failure-summary "Deadlock" 3)))
  (assert (= "Deadlock exited with an error" (failure-summary "Deadlock" 600)))
  (def cache (sh/exec-slurp "mktemp" "-d" (path/join (os/getenv "TMPDIR" "/tmp") "games-selftest-XXXXXXXX")))
  (defer (sh/exec "rm" "-rf" (string/trim cache))
    (def root (string/trim cache))
    (os/mkdir (path/join root "730"))
    (spit (path/join root "730" "logo.png") "")
    (spit (path/join root "730" "8dbc71957312bbd3baea65848b545be9eae2a355.jpg") "")
    (def games (enrich [{:app_id 730 :is_installed true} {:app_id 9 :is_installed true}
                        {:app_id 10 :is_installed false}] root))
    (assert (= 2 (length games)))
    (assert (= (path/join root "730" "8dbc71957312bbd3baea65848b545be9eae2a355.jpg") (get-in games [0 :icon])))
    (assert (nil? (get-in games [1 :icon]))))
  (print "ok"))

(defn main [script & args]
  (case (first args)
    "list" (list-games)
    "play" (if (>= (length args) 3)
             (play ;(slice args 1))
             (do (eprint "usage: games play NAME APP_ID [aurelia play flags]") (os/exit 2)))
    "selftest" (selftest)
    (do
      (eprint "usage: games list | games play NAME APP_ID [--steam]")
      (os/exit 2))))
