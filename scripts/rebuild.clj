(require '[babashka.process :refer [shell]])

(def host
  (let [h (System/getenv "NIX_HOST")]
    (when-not h (throw (ex-info "NIX_HOST is not set. Run a manual rebuild first." {})))
    h))

(def cmd
  (case host
    "macbook" "darwin-rebuild"
    "sudo nixos-rebuild"))

(println (str "Rebuilding " host "..."))
(shell cmd "switch" "--flake" (str ".#" host))
