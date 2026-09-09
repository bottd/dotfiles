(import spork/sh)

(defn main [script & args]
  (print "Removing node_modules...")
  (sh/rm "node_modules")
  (print "Removing package-lock.json...")
  (when (os/lstat "package-lock.json") (os/rm "package-lock.json"))
  (print "Cleaning npm cache...")
  (sh/exec-fail "npm" "cache" "clean" "--force")
  (print "Installing dependencies...")
  (sh/exec-fail "npm" "install"))
