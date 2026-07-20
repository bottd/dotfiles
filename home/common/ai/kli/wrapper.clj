(require '[babashka.process :as process]
         '[cheshire.core :as json]
         '[clojure.string :as str])

(def bw-bin "@bw@")
(def kli-bin "@kli@")
(def openssl-lib "@openssl-lib@")

(defn fail [message]
  (binding [*out* *err*]
    (println message))
  (System/exit 1))

(defn extract-kagi-api-key [item]
  (when-not (= 1 (:type item))
    (throw (ex-info "The kagi.com Bitwarden item is not a login." {})))
  (let [keys (->> (:fields item)
                  (filter #(= "API Key" (:name %)))
                  (map :value)
                  (filter string?)
                  (remove str/blank?))]
    (if (= 1 (count keys))
      (first keys)
      (throw (ex-info "Expected exactly one non-empty API Key field in the kagi.com Bitwarden item." {})))))

(defn kagi-api-key []
  (try
    (-> (process/shell {:out :string :err :inherit}
                       bw-bin "get" "item" "kagi.com")
        :out
        (json/parse-string true)
        extract-kagi-api-key)
    (catch Exception exception
      (fail (or (ex-message exception)
                "Unable to retrieve the kagi.com item from Bitwarden.")))))

(defn kli-environment [api-key]
  (let [environment (into {} (System/getenv))
        dyld-path (get environment "DYLD_LIBRARY_PATH")]
    (-> environment
        (dissoc "BW_SESSION" "BW_CLIENTID" "BW_CLIENTSECRET" "BW_PASSWORD")
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
