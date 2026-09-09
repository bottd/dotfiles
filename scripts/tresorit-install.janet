(import spork/path)
(import spork/sh)

(def installer-path "@tresorit-installer@")

(defn main [script & args]
  (def home (os/getenv "HOME"))
  (print "Running pinned Tresorit installer...")
  (with [proc (os/spawn ["sh" installer-path] :px {:in :pipe})]
    (ev/write (proc :in) "n\nn\n")
    (ev/close (proc :in))
    (os/proc-wait proc))
  (each suffix [".local/share/applications/tresorit.desktop"
                ".config/autostart/tresorit.desktop"]
    (sh/rm (path/join home suffix)))
  (print "Done! Launch Tresorit from the application menu."))
