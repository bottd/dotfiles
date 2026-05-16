;; quote-pack <task ...> -> `bb <task ...>` in $QUOTE_PACK_ROOT
;; (default ~/workspace/3rd-brain)

(require '[babashka.process :refer [shell]]
         '[clojure.string :as str])

(let [env (System/getenv "QUOTE_PACK_ROOT")
      pack-root (if (str/blank? env)
                  (str (System/getProperty "user.home") "/workspace/3rd-brain")
                  env)]
  (apply shell {:dir pack-root} "bb" *command-line-args*))
