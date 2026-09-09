(import spork/misc)
(import spork/path)
(import spork/sh)

(defn main [script src out]
  (defn walk [dir]
    (each name (os/dir dir)
      (unless (string/has-prefix? "." name)
        (def source (path/join dir name))
        (if (= :directory (os/lstat source :mode))
          (walk source)
          (when (string/has-suffix? ".fnl" name)
            (def relative (path/relpath src source))
            (def target (path/join out (string (misc/trim-suffix ".fnl" relative) ".lua")))
            (sh/create-dirs (path/dirname target))
            (with [output (file/open target :w)]
              (os/execute ["fennel" "--compile" source] :px {:out output})))))))
  (walk src))
