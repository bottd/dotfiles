(import spork/sh)
(import spork/path)
(import spork/argparse)

(defn valid-appearance [value]
  (when (or (= value "light") (= value "dark")) value))

(defn main [script & args]
  (def description "Pull the dotfiles repository and switch this host's configuration.")
  (def flags ["light" {:kind :flag :help "Use and save the light appearance."}
              "dark" {:kind :flag :help "Use and save the dark appearance."}])
  (def options
    (with-dyns [:out stderr]
      (argparse/argparse description :args ["rebuild" ;args] ;flags
                         "help" {:kind :flag :short "h" :short-circuit true
                                 :help "Show this help message."})))
  (unless options (os/exit 2))
  (when (options "help")
    (argparse/argparse description :args ["rebuild" "--help"] ;flags)
    (os/exit 0))
  (def home (os/getenv "HOME"))
  (def state-home (os/getenv "XDG_STATE_HOME" ""))
  (def appearance-file
    (path/join (if (empty? state-home) (path/join home ".local/state") state-home)
               "dotfiles/rebuild-appearance"))
  (def host (or (os/getenv "NIX_HOST")
                (error "NIX_HOST is not set. Run a manual rebuild first.")))
  (def flag-appearance (first (options :order)))
  (def saved-appearance
    (when (= :file (os/stat appearance-file :mode))
      (valid-appearance (string/trim (slurp appearance-file)))))
  (def appearance (or flag-appearance saved-appearance
                      (valid-appearance (os/getenv "NIX_APPEARANCE"))))
  (def config (if appearance (string host "-" appearance) host))
  (def cmd (if (= host "macbook") "darwin-rebuild" "nixos-rebuild"))
  (def flake-dir (path/join home "dotfiles"))
  (def cwd (os/cwd))
  (defer (os/cd cwd)
    (os/cd flake-dir)
    # Preserve the existing policy: a failed pull does not stop the rebuild.
    (sh/exec "git" "pull" "--rebase" "--quiet"))
  (sh/exec-fail "sudo" cmd "switch" "--flake" (string flake-dir "#" config))
  (when flag-appearance
    (sh/create-dirs (path/dirname appearance-file))
    (spit appearance-file flag-appearance)))
