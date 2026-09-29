(import spork/sh)
(import spork/path)
(import spork/json)
(import spork/argparse)

(defn parse-options [args]
  (def report @"")
  (def options
    (with-dyns [:out report]
      (argparse/argparse
        "Switch this host's current dotfiles checkout with nh."
        :args ["rebuild" ;args]
        "update" {:kind :flag :help "Pull the repository with --ff-only before switching."}
        "light" {:kind :flag :help "Use and save the light appearance."}
        "dark" {:kind :flag :help "Use and save the dark appearance."})))
  (when (string/has-prefix? "usage error:" report) (error (string report)))
  (when (and (get options "light") (get options "dark"))
    (error "Choose only one of --light and --dark."))
  (or options {:help (string report)}))

(defn configuration [host options saved]
  (def supported (host :appearances))
  (def requested (cond (options "light") "light" (options "dark") "dark"))
  (when (and requested (not (some |(= requested $) supported)))
    (error (string (host :hostName) " does not support --" requested ".")))
  (def appearance
    (when (not (empty? supported))
      (or requested (when (some |(= saved $) supported) saved) (host :appearance))))
  (if appearance (string (host :hostName) "-" appearance) (host :hostName)))

(defn checked-exec [argv directory]
  (def status ((dyn :rebuild-exec os/execute) argv :p {:cd directory}))
  (unless (zero? status)
    (error (string (first argv) " failed with exit status " status "."))))

(defn rebuild! [host options appearance-file]
  (def saved
    (when (= :file (os/stat appearance-file :mode))
      (string/trim (slurp appearance-file))))
  # Resolve and validate the entire plan before updating the checkout.
  (def target (configuration host options saved))
  (def platform (case (host :format) "nixos" "os" "darwin" "darwin"
                  (error "Unsupported host format.")))
  (def flake-dir (host :flakeDirectory))
  (when (options "update")
    (checked-exec ["git" "pull" "--ff-only"] flake-dir))
  # nh performs its own privilege elevation; it must start as the normal user.
  (checked-exec ["nh" platform "switch" flake-dir "--hostname" target
                 "--no-update-lock-file"] flake-dir)
  (when (or (options "light") (options "dark"))
    (sh/create-dirs (path/dirname appearance-file))
    (spit appearance-file (if (options "light") "light" "dark"))))

(defn fails? [f]
  (try (do (f) false) ([_] true)))

(defn selftest []
  (def desktop {:hostName "desktop" :format "nixos" :appearances ["light" "dark"]
                :appearance "light" :flakeDirectory "/tmp/checkout with spaces"})
  (def android (merge desktop {:hostName "android" :appearances [] :appearance "dark"}))
  (def mac (merge desktop {:hostName "renamed-mac" :format "darwin"}))
  (assert (= "desktop-light" (configuration desktop {} nil)))
  (assert (= "desktop-dark" (configuration desktop {} "dark")))
  (assert (= "desktop-light" (configuration desktop {"light" true} "dark")))
  (assert (= "desktop-light" (configuration desktop {} "invalid")))
  (assert (= "android" (configuration android {} "dark")))
  (assert (fails? (fn [] (configuration android {"dark" true} nil))))
  (assert (fails? (fn [] (parse-options ["--light" "--dark"]))))
  (assert (fails? (fn [] (parse-options ["--unknown"]))))
  (assert (fails? (fn [] (parse-options ["extra-argument"]))))
  (assert ((parse-options ["--update" "--dark"]) "dark"))
  (assert ((parse-options ["--help"]) :help))

  (def temp (sh/exec-slurp "mktemp" "-d"
                           (path/join (os/getenv "TMPDIR" "/tmp") "rebuild-test-XXXXXXXX")))
  (defer (sh/rm temp)
    (def state (path/join temp "state/appearance"))
    (def calls @[])
    (var failure nil)
    (defn fake-exec [argv flags options]
      (assert (= :p flags))
      (assert (= (desktop :flakeDirectory) (options :cd)))
      (array/push calls argv)
      (if (= (first argv) failure) 1 0))
    (with-dyns [:rebuild-exec fake-exec]
      # A normal rebuild does not pull, and does not need shell-specific variables.
      (rebuild! desktop {} state)
      (assert (deep= @[["nh" "os" "switch" (desktop :flakeDirectory)
                        "--hostname" "desktop-light" "--no-update-lock-file"]] calls))
      (assert (nil? (os/stat state)))

      (array/clear calls)
      (rebuild! mac {"dark" true "update" true} state)
      (assert (deep= ["git" "pull" "--ff-only"] (first calls)))
      (assert (= "darwin" (get-in calls [1 1])))
      (assert (= "renamed-mac-dark" (get-in calls [1 5])))
      (assert (= "dark" (string (slurp state))))

      (array/clear calls)
      (rebuild! android {} state)
      (assert (= "android" (get-in calls [0 5])))
      (assert (= "dark" (string (slurp state))))

      # Argument failure cannot cause a pull or a switch.
      (array/clear calls)
      (assert (fails? (fn [] (rebuild! android {"update" true "light" true} state))))
      (assert (empty? calls))

      # Pull failure stops the switch; switch failure preserves the preference.
      (each command ["git" "nh"]
        (array/clear calls)
        (set failure command)
        (assert (fails? (fn [] (rebuild! desktop {"update" true "light" true} state))))
        (assert (= (if (= command "git") 1 2) (length calls)))
        (assert (= "dark" (string (slurp state)))))
      (set failure nil)
      (rebuild! desktop {"light" true} state)
      (assert (= "light" (string (slurp state))))))
  (print "ok"))

(defn xdg-home [variable fallback]
  (def value (os/getenv variable ""))
  (if (empty? value) (path/join (os/getenv "HOME") fallback) value))

(defn main [script & args]
  (try
    (if (= ["selftest"] args)
      (selftest)
      (let [options (parse-options args)]
        (if (options :help)
          (print (options :help))
          (let [metadata (path/join (xdg-home "XDG_CONFIG_HOME" ".config") "dotfiles/host.json")
                appearance-file (path/join (xdg-home "XDG_STATE_HOME" ".local/state")
                                           "dotfiles/rebuild-appearance")]
            (unless (= :file (os/stat metadata :mode))
              (error "Missing dotfiles/host.json. Activate this host's configuration with a manual rebuild first."))
            (rebuild! (json/decode (slurp metadata) true) options appearance-file)))))
    ([err]
      (eprint err)
      (os/exit 1))))
