(require '[babashka.fs :as fs]
         '[babashka.process :as process])

(def installer-path "@tresorit-installer@")
(def home-dir (System/getProperty "user.home"))
(def vendor-shortcuts
  [(str home-dir "/.local/share/applications/tresorit.desktop")
   (str home-dir "/.config/autostart/tresorit.desktop")])

(println "Running pinned Tresorit installer...")
;; The upstream installer launches the binary directly when accepted. Keep
;; it inside the FHS launcher configured by Home Manager instead.
(process/shell {:in "n\nn\n"} "sh" installer-path)

;; Home Manager provides the FHS launcher and its autostart entry.
(doseq [shortcut vendor-shortcuts]
  (when (fs/exists? shortcut)
    (fs/delete shortcut)))

(println "Done! Launch Tresorit from the application menu.")
