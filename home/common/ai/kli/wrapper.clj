(require '[babashka.process :as process]
         '[clojure.string :as str])

(def rbw-bin "@rbw@")
(def kli-bin "@kli@")
(def openssl-lib "@openssl-lib@")

(defn fail [message]
  (binding [*out* *err*]
    (println message))
  (System/exit 1))

(defn kagi-api-key []
  (let [api-key (try
                  (-> (process/shell {:out :string
                                      :err :inherit}
                                     rbw-bin "get" "--field" "API Key" "kagi.com")
                      :out
                      str/trim)
                  (catch Exception _
                    (fail "Unable to retrieve the kagi.com API Key field from rbw.")))]
    (if (str/blank? api-key)
      (fail "The kagi.com API Key field is empty.")
      api-key)))

(defn kli-environment [api-key]
  (let [environment (into {} (System/getenv))
        dyld-path (get environment "DYLD_LIBRARY_PATH")]
    (-> environment
        (assoc "KAGI_API_KEY" api-key
               "DYLD_LIBRARY_PATH" (str openssl-lib
                                        (when-not (str/blank? dyld-path)
                                          (str ":" dyld-path)))))))

(defn -main [& args]
  (let [api-key (kagi-api-key)]
    (process/exec {:cmd (into [kli-bin] args)
                   :env (kli-environment api-key)})))

(when (= *file* (System/getProperty "babashka.file"))
  (apply -main *command-line-args*))
