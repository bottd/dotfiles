(require '[babashka.fs :as fs]
         '[babashka.http-client :as http]
         '[babashka.process :as process])

(def installer-url "https://installer.tresorit.com/tresorit_installer.run")
(def installer-path (fs/create-temp-file {:prefix "tresorit-installer-" :suffix ".run"}))
(def home-dir (System/getProperty "user.home"))
(def vendor-shortcuts
  [(str home-dir "/.local/share/applications/tresorit.desktop")
   (str home-dir "/.config/autostart/tresorit.desktop")])

(try
  (println "Downloading Tresorit installer...")
  (let [response (http/get installer-url {:as :bytes})]
    (when-not (= 200 (:status response))
      (throw (ex-info "Tresorit installer download failed" {:status (:status response)})))
    (fs/write-bytes installer-path (:body response)))

  (println "Running installer...")
  (process/shell "sh" (str installer-path))

  ;; Home Manager provides the FHS launcher and its autostart entry.
  (doseq [shortcut vendor-shortcuts]
    (when (fs/exists? shortcut)
      (fs/delete shortcut)))

  (println "Done! Launch Tresorit from the application menu.")
  (finally
    (fs/delete-if-exists installer-path)))
