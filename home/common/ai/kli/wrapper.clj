(require '[babashka.process :as process]
         '[clojure.string :as str])

(def rbw-bin "@rbw@")
(def kli-bin "@kli@")
(def openssl-lib "@openssl-lib@")

(def allowed-environment
  #{"COLORTERM" "EDITOR" "FORCE_COLOR" "HOME" "LANG"
    "LD_LIBRARY_PATH" "LOCALE_ARCHIVE" "LOCALE_ARCHIVE_2_27" "LOGNAME"
    "NIX_SSL_CERT_FILE" "NO_COLOR" "PAGER" "PATH" "SHELL" "SSL_CERT_FILE"
    "TZ" "USER" "VISUAL" "XDG_CACHE_HOME" "XDG_CONFIG_DIRS" "XDG_CONFIG_HOME"
    "XDG_DATA_DIRS" "XDG_DATA_HOME" "XDG_STATE_HOME"})

(def passthrough-prefixes ["BW_" "CLICOLOR" "KAGI_" "LC_" "RBW_" "TERM"])

(defn fail [message]
  (binding [*out* *err*]
    (println message))
  (System/exit 1))

(defn kagi-api-key []
  (let [api-key (or (some-> (System/getenv "KAGI_API_KEY") str/trim not-empty)
                    (try
                      (-> (process/shell {:out :string
                                          :err :inherit}
                                         rbw-bin "get" "--field" "API Key" "kagi.com")
                          :out
                          str/trim)
                      (catch Exception _
                        (fail "Unable to retrieve the kagi.com API Key field from rbw."))))]
    (if (str/blank? api-key)
      (fail "The kagi.com API Key field is empty.")
      api-key)))

(defn select-environment [environment]
  (into {} (filter (fn [[name]]
                     (or (contains? allowed-environment name)
                         (some #(str/starts-with? name %) passthrough-prefixes)))
                   environment)))

(defn kli-environment [api-key]
  (let [parent-environment (into {} (System/getenv))
        environment (select-environment parent-environment)
        dyld-path (get parent-environment "DYLD_LIBRARY_PATH")]
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
