(require '[babashka.fs :as fs])
(require '[babashka.process :refer [shell]])
(require '[babashka.http-client :as http])

(def installer-url "https://installer.tresorit.com/tresorit_installer.run")
(def installer-path "/tmp/tresorit_installer.run")

(println "Downloading Tresorit installer...")
(let [response (http/get installer-url {:as :bytes})]
  (fs/write-bytes installer-path (:body response)))

(println "Running installer...")
(shell "sh" installer-path)

(println "Cleaning up...")
(fs/delete installer-path)

(println "Done! Run 'tresorit-fhs' to launch.")
