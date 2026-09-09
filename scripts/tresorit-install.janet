(def installer-path "@tresorit-installer@")

(defn main [script & args]
  (def home (os/getenv "HOME"))
  (print "Running pinned Tresorit installer...")
  # Decline the direct binary launch; Home Manager supplies the FHS launcher.
  (with [proc (os/spawn ["sh" installer-path] :px {:in :pipe})]
    (ev/write (proc :in) "n\nn\n")
    (ev/close (proc :in))
    (os/proc-wait proc))
  (each suffix ["/.local/share/applications/tresorit.desktop"
                "/.config/autostart/tresorit.desktop"]
    (def shortcut (string home suffix))
    (when (os/stat shortcut) (os/rm shortcut)))
  (print "Done! Launch Tresorit from the application menu."))
