(import spork/path)
(import spork/sh)

# Tresorit only publishes this unversioned URL, so the installer can't be
# pinned by hash: the pin breaks on their next release. The client self-updates
# after the first run anyway.
(def installer-url "https://installer.tresorit.com/tresorit_installer.run")

(defn main [script & args]
  (def home (os/getenv "HOME"))
  (def dir (string/trim (sh/exec-slurp "mktemp" "-d" (path/join (os/getenv "TMPDIR" "/tmp") "tresorit-install-XXXXXXXX"))))
  (defer (sh/exec "rm" "-rf" dir)
    (def installer (path/join dir "tresorit_installer.run"))
    (print "Downloading the Tresorit installer...")
    (os/execute ["curl" "--fail" "--location" "--proto" "=https" "--progress-bar"
                 "--output" installer installer-url] :px)
    (print "Running the Tresorit installer...")
    (with [proc (os/spawn ["sh" installer] :px {:in :pipe})]
      (ev/write (proc :in) "n\nn\n")
      (ev/close (proc :in))
      (os/proc-wait proc)))
  (each suffix [".local/share/applications/tresorit.desktop"
                ".config/autostart/tresorit.desktop"]
    (sh/rm (path/join home suffix)))
  (print "Done! Launch Tresorit from the application menu."))
