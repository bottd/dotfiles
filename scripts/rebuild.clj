(require '[babashka.process :refer [shell]])

(def host
  (let [h (System/getenv "NIX_HOST")]
    (when-not h (throw (ex-info "NIX_HOST is not set. Run a manual rebuild first." {})))
    h))

(def appearance
  (some #(case % "--light" "light" "--dark" "dark" nil) *command-line-args*))

(def config
  (if appearance (str host "-" appearance) host))

(def cmd
  (case host
    "macbook" "darwin-rebuild"
    "nixos-rebuild"))

(shell "sudo" cmd "switch" "--flake" (str ".#" config))
