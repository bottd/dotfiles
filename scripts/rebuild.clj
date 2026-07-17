(require '[babashka.process :refer [shell]]
         '[clojure.string :as str])

(def home-dir (System/getProperty "user.home"))

(def appearance-file
  (java.io.File.
   (or (System/getenv "XDG_STATE_HOME") (str home-dir "/.local/state"))
   "dotfiles/rebuild-appearance"))

(defn valid-appearance [value]
  (when (#{"light" "dark"} value) value))

(def host
  (let [host (System/getenv "NIX_HOST")]
    (when-not host (throw (ex-info "NIX_HOST is not set. Run a manual rebuild first." {})))
    host))

(def flag-appearance
  (some #(case % "--light" "light" "--dark" "dark" nil) *command-line-args*))

(def saved-appearance
  (when (.isFile appearance-file)
    (valid-appearance (str/trim (slurp appearance-file)))))

(def appearance
  (or flag-appearance
      saved-appearance
      (valid-appearance (System/getenv "NIX_APPEARANCE"))))

(when flag-appearance
  (.mkdirs (.getParentFile appearance-file))
  (spit appearance-file flag-appearance))

(def config
  (if appearance (str host "-" appearance) host))

(def cmd
  (case host
    "macbook" "darwin-rebuild"
    "nixos-rebuild"))

(def flake-dir (str (System/getProperty "user.home") "/dotfiles"))

(shell {:dir flake-dir :continue true} "git" "pull" "--rebase" "--quiet")

(shell "sudo" cmd "switch" "--flake" (str flake-dir "#" config))
