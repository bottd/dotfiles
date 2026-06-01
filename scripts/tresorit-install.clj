(require '[babashka.fs :as fs]
         '[babashka.process :refer [shell]]
         '[babashka.http-client :as http]
         '[clojure.string :as str])

(def installer-url "https://installer.tresorit.com/tresorit_installer.run")
(def installer-path "/tmp/tresorit_installer.run")
(def tresorit-dir (str (System/getenv "HOME") "/.local/share/tresorit"))
(def launcher-path (str tresorit-dir "/tresorit_fhs_launcher.sh"))

(println "Downloading Tresorit installer...")
(let [response (http/get installer-url {:as :bytes})]
  (fs/write-bytes installer-path (:body response)))

(println "Running installer...")
(shell "sh" installer-path)

(println "Cleaning up...")
(fs/delete installer-path)

(println "Patching launcher for Wayland/KDE compatibility...")
(when (fs/exists? launcher-path)
  (let [content (slurp launcher-path)
        patched (if (str/includes? content "QT_QPA_PLATFORM")
                  content
                  (str/replace content
                               "printf \"Starting Tresorit within FHS environment...\\n\""
                               "printf \"Starting Tresorit within FHS environment...\\n\"\nexport QT_QPA_PLATFORM=xcb\nexport QT_STYLE_OVERRIDE="))]
    (spit launcher-path patched)
    (println "Launcher patched successfully.")))

(println "Done! Run 'tresorit' to launch.")
