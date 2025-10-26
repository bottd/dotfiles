(require '[babashka.fs :as fs])
(require '[babashka.process :refer [shell]])

(println "Removing node_modules...")
(fs/delete-tree "node_modules")

(println "Removing package-lock.json...")
(fs/delete-if-exists "package-lock.json")

(println "Cleaning npm cache...")
(shell "npm cache clean --force")

(println "Installing dependencies...")
(shell "npm install")
