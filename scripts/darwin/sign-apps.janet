# Safely prepare copied Home Manager app bundles for Gatekeeper.

(import spork/sh)
(import spork/path)

(defn warn! [message]
  (eprint message))

(defn fail! [message]
  (error message))

(defn exec [options args]
  (def env @{:out (dyn :out stdout) :err (dyn :err stderr)})
  (when (options :out) (put env :out :pipe))
  (when (options :err) (put env :err :pipe))
  # Drain both pipes while waiting, and close them even on failure. Unlike
  # exec-slurp-all, keep trailing whitespace for the exact xattr line checks.
  (with [proc (os/spawn args :p env)]
    (def [out err status]
      (ev/gather
        (when (options :out) (ev/read (proc :out) :all))
        (when (options :err) (ev/read (proc :err) :all))
        (os/proc-wait proc)))
    {:status status :out (string (or out "")) :err (string (or err ""))}))

(defn shell [options & args]
  (def result ((dyn :sign-apps-exec exec) options args))
  (when (and (not (options :continue)) (not (zero? (result :status))))
    (fail! (result :err)))
  result)

(defn owner [uid]
  (def result (sh/exec-slurp-all "id" "-nu" (string uid)))
  (if (zero? (result :status)) (result :out) (string uid)))

(defn provenance? [output]
  (not (nil?
         (some (fn [line]
                 (peg/match
                   '{:main (+ (* "com.apple.provenance" :end)
                              (* (to :attribute) :attribute))
                     :attribute (* ": com.apple.provenance" :end)
                     :end (* (? (+ "\r" "\u0085" "\u2028" "\u2029")) -1)}
                   line))
               (string/split "\n" (string/replace-all "\r\n" "\n" output))))))

(defn valid-signature? [app]
  (zero? ((shell {:continue true :out true :err true}
                 "/usr/bin/codesign" "--verify" "--deep" "--strict" app) :status)))

(defn sign-app! [app current-uid]
  (def stat ((dyn :sign-apps-lstat os/lstat) app))
  (cond
    (= :link (get stat :mode))
    (warn! (string "Skipping symlinked application: " app))

    (not= :directory (get stat :mode)) nil

    (not= current-uid (stat :uid))
    (warn! (string "Skipping " app " owned by " (owner (stat :uid))))

    (let [attributes ((shell {:out true} "/usr/bin/xattr" "-r" "-s" app) :out)
          tainted? (provenance? attributes)
          unsigned? (not (valid-signature? app))]
      # Both repairs need the bundle writable, but the steady state is
      # already-signed and provenance-free, so decide before touching modes.
      (when (or tainted? unsigned?)
        (shell {} "/bin/chmod" "-R" "u+w" app)
        (when tainted?
          (shell {} "/usr/bin/xattr" "-d" "-r" "-s" "com.apple.provenance" app))
        (when unsigned?
          (shell {} "/usr/bin/codesign" "--force" "--deep" "--sign" "-" app)
          (shell {} "/usr/bin/codesign" "--verify" "--deep" "--strict" app))))))

# Only repair bundles the invoking user owns. Resolve the UID with id -u,
# never USER; lstat checks the link itself rather than its target's owner.
(defn sign-apps! [apps-dir current-uid]
  # Java Path removes redundant/trailing slashes, but does not resolve dot segments.
  # In particular, a trailing slash must not make lstat follow a root symlink.
  (def apps-dir (string (peg/replace-all '(some "/") "/" apps-dir)))
  (def apps-dir (if (= apps-dir "/") apps-dir (string/trimr apps-dir "/")))
  (def stat ((dyn :sign-apps-lstat os/lstat) (if (= apps-dir "") "." apps-dir)))
  (cond
    (= :link (get stat :mode))
    (fail! (string "Refusing to modify symlinked directory: " apps-dir))

    (not= :directory (get stat :mode)) nil

    (not= current-uid (stat :uid))
    (fail! (string "Refusing to modify " apps-dir " owned by " (owner (stat :uid))))

    (each name (os/dir (if (= apps-dir "") "." apps-dir))
      (def app (string apps-dir
                       (if (or (= apps-dir "") (= apps-dir "/")) "" "/")
                       name))
      # Match fs/glob's nonrecursive walk: hidden entries and directory
      # subtrees are skipped, while symlinks still reach the no-follow guard.
      (when (and (not (string/has-prefix? "." name))
                 (string/has-suffix? ".app" name)
                 (not= :directory (os/lstat app :mode)))
        (sign-app! app current-uid)))))

(defn fails? [f]
  (try (do (f) false) ([_] true)))

(defn selftest []
  (assert (provenance? "Fixture.app: com.apple.provenance"))
  (assert (provenance? "com.apple.provenance"))
  (assert (not (provenance? "Fixture.app: com.apple.quarantine")))
  (assert (provenance? "Fixture.app: com.apple.provenance\r\n"))
  (assert (provenance? "Fixture.app: com.apple.provenance\r\r\n"))
  (assert (not (provenance? "Fixture.app: com.apple.provenance\r\r")))
  (each suffix ["\u0085" "\u2028" "\u2029"]
    (assert (provenance? (string "com.apple.provenance" suffix))))
  (assert (not (provenance? "Fixture.app: com.apple.provenance ")))
  (assert (not (provenance? "notcom.apple.provenance")))

  (def uid (scan-number (sh/exec-slurp "id" "-u")))
  (def temp (sh/exec-slurp "mktemp" "-d"
                           (path/join (os/getenv "TMPDIR" "/tmp") "sign-home-manager-apps-XXXXXXXX")))
  (defer (sh/rm temp)
    (def missing (path/join temp "missing"))
    (def target (path/join temp "target"))
    (def root-link (path/join temp "root-link"))
    (def apps-dir (path/join temp "apps"))
    (def app-link (path/join apps-dir "Fixture.app"))
    (os/mkdir target)
    (os/mkdir apps-dir)
    (os/link target root-link true)
    (os/link target app-link true)
    (os/link missing (path/join apps-dir "Broken.app") true)
    (os/link target (path/join apps-dir ".Hidden.app") true)
    (spit (path/join apps-dir "File.app") "")
    (os/mkdir (path/join apps-dir "Directory.app"))
    (assert (= uid (os/lstat apps-dir :uid)))
    # An unexpected command must fail the test, never reach a real app tool.
    (with-dyns [:sign-apps-exec (fn [& _] (error "unexpected signing command"))
                :err @""]
      (sign-apps! missing uid)
      (assert (fails? (fn [] (sign-apps! root-link uid))))
      (assert (fails? (fn [] (sign-apps! (string root-link "/") uid))))
      (sign-apps! apps-dir uid)
      (assert (= :link (os/lstat app-link :mode)))
      (assert (string/has-prefix? "Skipping symlinked application: " (dyn :err)))
      (assert (nil? (string/find ".Hidden.app" (dyn :err)))))

    (def app (path/join apps-dir "Owned.app"))
    (os/mkdir app)
    (def calls @[])
    (var tainted false)
    (var unsigned false)
    (var failure nil)
    (defn fake-exec [options args]
      (array/push calls args)
      {:status (if (or (= (length calls) failure)
                       (and unsigned (options :continue))) 1 0)
       :out (if tainted "Owned.app: com.apple.provenance\n" "")
       :err "fixture failure"})
    (with-dyns [:sign-apps-exec fake-exec :err @""]
      (each [taint sign expected] [[false false 2] [true false 4]
                                   [false true 5] [true true 6]]
        (set tainted taint)
        (set unsigned sign)
        (array/clear calls)
        (sign-app! app uid)
        (def expected-calls @[(tuple "/usr/bin/xattr" "-r" "-s" app)
                              (tuple "/usr/bin/codesign" "--verify" "--deep" "--strict" app)])
        (when (or taint sign)
          (array/push expected-calls (tuple "/bin/chmod" "-R" "u+w" app)))
        (when taint
          (array/push expected-calls (tuple "/usr/bin/xattr" "-d" "-r" "-s" "com.apple.provenance" app)))
        (when sign
          (array/push expected-calls
                      (tuple "/usr/bin/codesign" "--force" "--deep" "--sign" "-" app)
                      (tuple "/usr/bin/codesign" "--verify" "--deep" "--strict" app)))
        (assert (= expected (length calls)))
        (assert (deep= expected-calls calls)))
      # Failure at any repair stage, including the final verification, stops.
      (each index [1 3 4 5 6]
        (array/clear calls)
        (set failure index)
        (assert (fails? (fn [] (sign-app! app uid))))
        (assert (= index (length calls))))
      (array/clear calls)
      (with-dyns [:sign-apps-lstat (fn [_] {:mode :directory :uid (+ uid 1)})]
        (assert (fails? (fn [] (sign-apps! apps-dir uid))))
        (sign-app! app uid))
      (assert (empty? calls))))
  (print "ok"))

(defn main [script & args]
  (try
    (cond
      (= ["selftest"] args) (selftest)
      (= 1 (length args))
      (sign-apps! (first args) (scan-number (sh/exec-slurp "id" "-u")))
      (do
        (warn! "usage: darwin-sign-apps <apps-dir> | selftest")
        (os/exit 2)))
    ([error]
      (warn! (string error))
      (os/exit 1))))
