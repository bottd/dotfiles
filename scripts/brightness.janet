(import spork/sh :as shell)
(import spork/path)
(import cmd)

(def step 5)
(def vcp-brightness "10")
(def backlight-dir "/sys/class/backlight")
(def cache-seconds 60)

(defn with-lock [lock-path f]
  (with [lock (file/open lock-path :an)]
    (os/execute ["flock" "--exclusive" "0"] :px {:in lock})
    (f)))

(defn sh [& args]
  (try
    (let [result ((dyn :brightness-exec shell/exec-slurp-all) ;args)]
      (when (zero? (result :status)) (result :out)))
    ([_] nil)))

(defn parse-integer [value]
  (when (and value (peg/match '(* (? (set "+-")) :d+ -1) value))
    (scan-number value)))

(defn split-lines [out]
  (string/split "\n" (string/replace-all "\r\n" "\n" (or out ""))))

(defn backlight? []
  (def dir (dyn :brightness-backlight-dir backlight-dir))
  (and (= :directory (os/stat dir :mode)) (pos? (length (os/dir dir)))))

(defn parse-backlight [out]
  (when out
    (when-let [percent (get (string/split "," (first (split-lines out))) 3)]
      (parse-integer (string/replace-all "%" "" percent)))))

(defn parse-buses [out]
  (keep (fn [line]
          (first (peg/match
                   '{:main (* (to :bus) :bus)
                     :bus (* "I2C bus:" :s+ "/dev/i2c-" (<- :d+))}
                   line)))
        (split-lines out)))

(defn parse-vcp [out]
  (when-let [[current maximum]
             (peg/match
               '{:main (* (to :vcp) :vcp)
                 :vcp (* "VCP" :s+ :S+ :s+ "C" :s+ (<- :d+) :s+ (<- :d+))}
               (or out ""))]
    (def current (parse-integer current))
    (def maximum (parse-integer maximum))
    (unless (zero? maximum)
      {:current current :maximum maximum
       :percent (math/round (/ (* 100 current) maximum))})))

(defn runtime-dir []
  (or (os/getenv "XDG_RUNTIME_DIR")
      (let [uid (scan-number (shell/exec-slurp "id" "-u"))
            dir (path/join (dyn :brightness-tmp-dir "/tmp") (string "brightness-" uid))]
        (os/mkdir dir)
        (def info (os/lstat dir))
        (unless (and (= :directory (get info :mode)) (= uid (get info :uid)))
          (error (string dir " is not a directory owned by uid " uid)))
        (os/chmod dir 8r700)
        dir)))

(defn buses []
  (def cache (dyn :brightness-bus-cache))
  (with-lock (string cache ".lock")
    (fn []
      (def info (os/stat cache))
      (def cached (when info
                    (filter |(peg/match '(* :d+ -1) $) (split-lines (slurp cache)))))
      (def age (when info (- (os/time) (info :modified))))
      (if (and age (<= 0 age) (< age cache-seconds))
        cached
        (let [found (parse-buses (sh "ddcutil" "detect" "--brief"))
              buses (if (empty? found) (or cached @[]) found)
              temp (string cache ".tmp")]
          (defer (when (os/lstat temp) (os/rm temp))
            (spit temp (string/join buses "\n"))
            (os/rename temp cache))
          buses)))))

(defn on-buses [f]
  (ev/go-gather
    (map (fn [bus]
           (fn []
             (with-lock (string (dyn :brightness-bus-cache) ".bus-" bus ".lock")
               (fn [] (f bus)))))
         (buses))))

(defn on-buses! [f]
  (def results (on-buses f))
  (unless (some |(not (nil? $)) results)
    (def cache (dyn :brightness-bus-cache))
    (with-lock (string cache ".lock")
      (fn [] (when (os/lstat cache) (os/rm cache)))))
  results)

(defn ddc-read [bus]
  (parse-vcp (sh "ddcutil" "--bus" bus "getvcp" vcp-brightness "--brief")))

(defn ddc-write [bus percent-fn &opt delta]
  (when-let [{:current current :maximum maximum :percent percent} (ddc-read bus)]
    (def target (min 100 (max 0 (percent-fn percent))))
    (def raw (math/round (/ (* target maximum) 100)))
    (def raw (cond
               (and delta (pos? delta)) (min maximum (max raw (inc current)))
               (and delta (neg? delta)) (max 0 (min raw (dec current)))
               raw))
    (sh "ddcutil" "--bus" bus "setvcp" vcp-brightness (string raw))))

(defn current []
  (if (backlight?)
    (parse-backlight (sh "brightnessctl" "--class=backlight" "-m"))
    (some |(get $ :percent) (on-buses ddc-read))))

(defn apply-brightness [ctl-arg percent-fn &opt delta]
  (if (backlight?)
    (sh "brightnessctl" "--class=backlight" "set" ctl-arg)
    (on-buses! |(ddc-write $ percent-fn delta))))

(defn adjust [delta]
  (apply-brightness (string (math/abs delta) "%" (if (pos? delta) "+" "-"))
                    (fn [percent] (+ percent delta))
                    delta))

(defn selftest []
  (assert (= 42 (parse-backlight "intel_backlight,backlight,1000,42%,2000")))
  (assert (nil? (parse-backlight "")))
  (assert (nil? (parse-backlight nil)))
  (assert (= 42 (parse-backlight "panel,backlight,1000,42%\r\nignored")))
  (assert (deep= @["6" "8"]
                 (parse-buses (string "Display 1\n"
                                      "   I2C bus:          /dev/i2c-6\n"
                                      "   Monitor:          ACR:XV272U V:4117181784205\n"
                                      "\n"
                                      "Display 2\n"
                                      "   I2C bus:          /dev/i2c-8\n"))))
  (assert (deep= @[] (parse-buses nil)))
  (assert (deep= {:current 45 :maximum 100 :percent 45} (parse-vcp "VCP 10 C 45 100")))
  (assert (deep= {:current 5 :maximum 10 :percent 50} (parse-vcp "VCP 10 C 5 10")))
  (assert (nil? (parse-vcp "DDC communication failed")))
  (assert (nil? (parse-vcp "VCP 10 C 0 0")))
  (assert (deep= {:current 1 :maximum 8 :percent 13} (parse-vcp "VCP 10 C 1 8")))
  (each value ["1.5" "1e2" "0xff" " 40" "40 " "" "-"]
    (assert (nil? (parse-integer value))))
  (assert (= 1 (parse-integer "+001")))
  (assert (= -7 (parse-integer "-7")))

  (def temp (shell/exec-slurp "mktemp" "-d"
                              (path/join (os/getenv "TMPDIR" "/tmp") "brightness-selftest-XXXXXXXX")))
  (defer (shell/rm temp)
    (def cache (path/join temp "buses"))
    (def panel (path/join temp "backlight"))

    (def saved-runtime (os/getenv "XDG_RUNTIME_DIR"))
    (defer (os/setenv "XDG_RUNTIME_DIR" saved-runtime)
      (os/setenv "XDG_RUNTIME_DIR" (path/join temp "xdg"))
      (assert (= (path/join temp "xdg") (runtime-dir)))
      (os/setenv "XDG_RUNTIME_DIR" nil)
      (with-dyns [:brightness-tmp-dir temp]
        (def uid (scan-number (shell/exec-slurp "id" "-u")))
        (def dir (path/join temp (string "brightness-" uid)))
        (assert (= dir (runtime-dir)))
        (assert (= dir (runtime-dir)))
        (assert (= "rwx------" (os/lstat dir :permissions)))
        (assert (= uid (os/lstat dir :uid)))
        (os/rmdir dir)
        (spit dir "")
        (assert (not (first (protect (runtime-dir)))))
        (os/rm dir)))
    (def calls @[])
    (var failing false)
    (var detected "I2C bus: /dev/i2c-6\nI2C bus: /dev/i2c-8")
    (var active 0)
    (var peak 0)
    (with-dyns [:brightness-bus-cache cache
                :brightness-backlight-dir panel
                :brightness-exec
                (fn [& args]
                  (array/push calls args)
                  (++ active)
                  (set peak (max peak active))
                  (ev/sleep 0.01)
                  (-- active)
                  (if failing
                    {:status 1 :out "VCP 10 C 5 10" :err "failure"}
                    {:status 0 :err ""
                     :out (cond
                            (= "brightnessctl" (first args)) "panel,backlight,5,50%,10"
                            (= "detect" (get args 1)) detected
                            (= "getvcp" (get args 3)) "VCP 10 C 5 10"
                            "")}))]
      (assert (= 50 (current)))
      (assert (= 2 peak))
      (assert (= "6\n8" (string (slurp cache))))
      (array/clear calls)
      (adjust (- step))
      (assert (deep= @[(tuple "ddcutil" "--bus" "6" "setvcp" "10" "4")
                       (tuple "ddcutil" "--bus" "8" "setvcp" "10" "4")]
                     (sorted-by |(get $ 2) (filter |(= "setvcp" (get $ 3)) calls))))
      (assert (os/stat cache))
      (array/clear calls)
      (apply-brightness "45%" (fn [_] 45))
      (assert (all |(= "5" (last $)) (filter |(= "setvcp" (get $ 3)) calls)))
      (set detected (string detected "\nI2C bus: /dev/i2c-9"))
      (assert (deep= @["6" "8"] (buses)))
      (os/touch cache 0 (- (os/time) cache-seconds 1))
      (assert (deep= @["6" "8" "9"] (buses)))
      (array/clear calls)
      (spit cache " \n6\r\n\n8\n")
      (assert (deep= @[nil 0] (on-buses! |(when (= $ "8") 0))))
      (assert (os/stat cache))
      (assert (empty? calls))
      (set failing true)
      (assert (nil? (current)))
      (assert (os/stat cache))
      (assert (nil? (current)))
      (assert (os/stat cache))
      (assert (not (some |(= "detect" (get $ 1)) calls)))
      (adjust step)
      (assert (nil? (os/stat cache)))
      (array/clear calls)
      (assert (nil? (current)))
      (assert (deep= @[(tuple "ddcutil" "detect" "--brief")] calls))
      (assert (os/stat cache))
      (array/clear calls)
      (assert (nil? (current)))
      (assert (empty? calls))
      (os/mkdir panel)
      (spit (path/join panel "fixture") "")
      (array/clear calls)
      (assert (nil? (current)))
      (assert (deep= @[(tuple "brightnessctl" "--class=backlight" "-m")] calls))
      (set failing false)
      (assert (= 50 (current)))
      (array/clear calls)
      (adjust step)
      (assert (deep= @[(tuple "brightnessctl" "--class=backlight" "set" "5%+")] calls)))
    (with-dyns [:brightness-exec (fn [& _] (error "missing executable"))]
      (assert (nil? (sh "ddcutil")))))
  (print "ok"))

(def commands
  (cmd/group "Read or change display brightness. With no command, report the current percentage."
             "get" (cmd/fn "Report the current percentage." []
                           (when-let [percent (current)] (print percent)))
             "up" (cmd/fn "Increase brightness by five percentage points." [] (adjust step))
             "down" (cmd/fn "Decrease brightness by five percentage points." [] (adjust (- step)))
             "set" (cmd/fn "Set brightness, clamped to 0-100 percent."
                           [percent (required ["PERCENT" (fn [value]
                                                           (or (parse-integer value)
                                                               (error "expected a decimal integer")))])
                            -- (escape)]
                           (def percent (min 100 (max 0 percent)))
                           (apply-brightness (string percent "%") (fn [_] percent)))
             "selftest" (cmd/fn "Run the built-in checks." [] (selftest))))

(defn main [script & args]
  (def [command argument] args)
  (def args
    (cond
      (nil? command) ["get"]
      (or (= command "--help") (= command "-h")) ["help" ;(drop 1 args)]
      (and (= command "set") argument
           (string/has-prefix? "-" argument) (parse-integer argument))
      ["set" "--" ;(drop 1 args)]
      args))
  (with-dyns [:args ["brightness" ;args]
              :brightness-bus-cache (path/join (runtime-dir) "brightness-ddc-buses")]
    (cmd/run commands args)))
