# Brightness for whatever kind of display the host has: internal panels expose
# /sys/class/backlight and go through brightnessctl, desktop monitors have no
# such device and are driven over DDC/CI on the i2c bus instead.
#
#   brightness           # current percentage, or nothing if nothing answers
#   brightness up
#   brightness down
#   brightness set 40

(import spork/sh :as shell)
(import spork/path)
(import cmd)

(def step 5)
# VCP 0x10 is the DDC/CI brightness register.
(def vcp-brightness "10")
(def backlight-dir "/sys/class/backlight")
(def cache-seconds 60)

(defn with-lock [lock-path f]
  (with [lock (file/open lock-path :an)]
    # flock locks the inherited open-file description; our handle keeps it held.
    # Keep the lock file itself: unlinking it would split concurrent lock users.
    (os/execute ["flock" "--exclusive" "0"] :px {:in lock})
    (f)))

(defn exec [& args]
  # Drain both streams while waiting, and retain output verbatim for the parsers.
  (with [proc (os/spawn args :p {:out :pipe :err :pipe})]
    (def [out err status]
      (ev/gather (ev/read (proc :out) :all)
                 (ev/read (proc :err) :all)
                 (os/proc-wait proc)))
    {:status status :out (string (or out "")) :err (string (or err ""))}))

# nil rather than an error: "nothing answered" is ordinary here.
(defn sh [& args]
  (try
    (let [result ((dyn :brightness-exec exec) ;args)]
      (when (zero? (result :status)) (result :out)))
    ([_] nil)))

(defn unbox [value]
  (try (int/to-number value) ([_] value)))

(defn as-number [value]
  (if (number? value) value (scan-number (string value) 10)))

(defn parse-long [value]
  (when (and value (peg/match '(* (? (set "+-")) :d+ -1) value))
    # Keep large integers boxed rather than losing digits in Janet's doubles.
    (try (unbox (int/s64 value)) ([_] nil))))

# Java Math.round chooses the upper integer at ties, including negative ties.
(defn round [value]
  (cond
    (nan? value) 0
    (>= value 9223372036854775808) (int/s64 "9223372036854775807")
    (<= value -9223372036854775808) (int/s64 "-9223372036854775808")
    (let [lower (math/floor value)]
      (unbox (int/s64 (string/format "%.0f" (+ lower (if (>= (- value lower) 0.5) 1 0))))))))

(defn split-lines [out]
  (string/split "\n" (string/replace-all "\r\n" "\n" (or out ""))))

(defn backlight? []
  (def dir (dyn :brightness-backlight-dir backlight-dir))
  (and (= :directory (os/stat dir :mode)) (pos? (length (os/dir dir)))))

# `brightnessctl -m` is device,class,current,percentage,max.
(defn parse-backlight [out]
  (when out
    (when-let [percent (get (string/split "," (first (split-lines out))) 3)]
      (parse-long (string/replace-all "%" "" percent)))))

(defn parse-buses [out]
  (keep (fn [line]
          (first (peg/match
                   '{:main (* (to :bus) :bus)
                     :bus (* "I2C bus:" :s+ "/dev/i2c-" (<- :d+))}
                   line)))
        (split-lines out)))

# Maxima vary by monitor, so carry it alongside the percentage.
(defn parse-vcp [out]
  (when-let [[current maximum]
             (peg/match
               '{:main (* (to :vcp) :vcp)
                 :vcp (* "VCP" :s+ :S+ :s+ "C" :s+ (<- :d+) :s+ (<- :d+))}
               (or out ""))]
    (def current (parse-long current))
    (def maximum (parse-long maximum))
    (when (zero? maximum) (error "Divide by zero"))
    {:current current :maximum maximum
     :percent (round (/ (* 100.0 (as-number current)) (as-number maximum)))}))

# The DRM connector's ddc/i2c-dev bus is not necessarily the one ddcutil
# speaks on, so detect is the only answer.
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
              # Retain sleeping monitors, but retry discovery at most once a minute.
              buses (if (empty? found) (or cached @[]) found)
              temp (shell/exec-slurp "mktemp" (string cache ".XXXXXXXX"))]
          (defer (when (os/lstat temp) (os/rm temp))
            (spit temp (string/join buses "\n"))
            (os/rename temp cache))
          buses)))))

# In parallel: sequentially this is slow enough to feel like lag on a held key.
(defn on-buses [f]
  (ev/go-gather
    (map (fn [bus]
           (fn []
             # Cover the entire callback, including a write's read-modify-write.
             (with-lock (string (dyn :brightness-bus-cache) ".bus-" bus ".lock")
               (fn [] (f bus)))))
         (buses))))

# Only a write invalidates. Polling a sleeping monitor must not turn every
# `get` into a ~1s bus scan. One answering monitor is enough to keep the cache.
(defn on-buses! [f]
  (def results (on-buses f))
  (unless (some |(not (nil? $)) results)
    (def cache (dyn :brightness-bus-cache))
    (with-lock (string cache ".lock")
      (fn [] (when (os/lstat cache) (os/rm cache)))))
  results)

(defn ddc-read [bus]
  (parse-vcp (sh "ddcutil" "--bus" bus "getvcp" vcp-brightness "--brief")))

# setvcp takes a raw value, so each display has to report its own maximum.
(defn ddc-write [bus percent-fn &opt delta]
  (when-let [{:current current :maximum maximum :percent percent} (ddc-read bus)]
    (def target (int/s64 (min 100 (max 0 (as-number (percent-fn percent))))))
    (def raw (* target (int/s64 maximum)))
    # Janet's boxed arithmetic wraps; Clojure's integer multiplication throws.
    (when (and (not= target (int/s64 0)) (not= (/ raw target) (int/s64 maximum)))
      (error "long overflow"))
    (def raw (round (/ (as-number raw) 100.0)))
    # Relative steps must move even when percentage rounding lands on the old value.
    # Absolute `set` retains its nearest-integer rounding.
    (def raw (cond
               (and delta (pos? delta))
               (min (as-number maximum) (max (as-number raw) (inc (as-number current))))
               (and delta (neg? delta))
               (max 0 (min (as-number raw) (dec (as-number current))))
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

# brightnessctl steps natively while DDC has to read-add-write. Derive both
# forms from the one delta to keep them from drifting apart.
(defn adjust [delta]
  (apply-brightness (string (math/abs delta) "%" (if (pos? delta) "+" "-"))
                    (fn [percent]
                      (def previous (int/s64 percent))
                      (def target (+ previous (int/s64 delta)))
                      (when (if (pos? delta) (< target previous) (> target previous))
                        (error "long overflow"))
                      (unbox target))
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
  (assert (deep= {:current 1 :maximum 8 :percent 13} (parse-vcp "VCP 10 C 1 8")))
  (each [value expected] [[4.5 5] [-4.5 -4] [0.49999999999999994 0]]
    (assert (= expected (round value))))
  (each value ["1.5" "1e2" "0xff" " 40" "40 " "9223372036854775808" "-9223372036854775809"]
    (assert (nil? (parse-long value))))
  (assert (= 1 (parse-long "+001")))
  (each value ["9223372036854775807" "-9223372036854775808" "9007199254740993"]
    (assert (= value (string (parse-long value)))))
  (assert (= "9223372036854775807" (string (round math/inf))))
  (assert (= "-9223372036854775808" (string (round (- math/inf)))))
  (assert (= 0 (round math/nan)))

  # Only this private cache/backlight fixture is written; every device command is stubbed.
  (def temp (shell/exec-slurp "mktemp" "-d"
                              (path/join (os/getenv "TMPDIR" "/tmp") "brightness-selftest-XXXXXXXX")))
  (defer (shell/rm temp)
    (def cache (path/join temp "buses"))
    (def panel (path/join temp "backlight"))
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
      # Independent buses may finish in either order.
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
                                                           (or (parse-long value)
                                                               (error "expected a decimal integer")))])
                            -- (escape)]
                           (def percent (min 100 (max 0 (as-number percent))))
                           (apply-brightness (string percent "%") (fn [_] percent)))
             "selftest" (cmd/fn "Run the built-in checks." [] (selftest))))

(defn main [script & args]
  (def [command argument] args)
  (def args
    (cond
      (nil? command) ["get"]
      (or (= command "--help") (= command "-h")) ["help" ;(drop 1 args)]
      # cmd treats negative positionals as flags; retain `brightness set -10`.
      (and (= command "set") argument
           (string/has-prefix? "-" argument) (parse-long argument))
      ["set" "--" ;(drop 1 args)]
      args))
  # `ddcutil detect` costs about a second, so remember which buses answered.
  # Resolve the account via id, not the caller-controlled USER environment variable.
  (with-dyns [:args ["brightness" ;args]
              :brightness-bus-cache
              (path/join (os/getenv "XDG_RUNTIME_DIR" "/tmp")
                         (string "brightness-ddc-buses-" (shell/exec-slurp "id" "-un")))]
    (cmd/run commands args)))
