;; Safely prepare copied Home Manager app bundles for Gatekeeper.

(require '[babashka.fs :as fs]
         '[babashka.process :as p]
         '[clojure.string :as str])

(defn warn! [message]
  (binding [*out* *err*]
    (println message)))

(defn fail! [message]
  (throw (ex-info message {})))

(def current-user (System/getProperty "user.name"))

(defn owner [path]
  (str (fs/owner path {:nofollow-links true})))

(defn provenance? [output]
  (boolean
   (some #(re-find #"(?:^|: )com\.apple\.provenance$" %)
         (str/split-lines output))))

(defn valid-signature? [app]
  (zero?
   (:exit
    (p/shell {:continue true :out :string :err :string}
             "/usr/bin/codesign" "--verify" "--deep" "--strict" (str app)))))

(defn sign-app! [app]
  (cond
    (fs/sym-link? app)
    (warn! (str "Skipping symlinked application: " app))

    (not (fs/directory? app {:nofollow-links true}))
    nil

    :else
    (let [app-owner (owner app)]
      (if (not= current-user app-owner)
        (warn! (str "Skipping " app " owned by " app-owner))
        ;; Both repairs need the bundle writable, but the steady state is
        ;; already-signed and provenance-free, so decide before touching modes.
        (let [attributes (:out (p/shell {:out :string}
                                        "/usr/bin/xattr" "-r" "-s" (str app)))
              tainted? (provenance? attributes)
              unsigned? (not (valid-signature? app))]
          (when (or tainted? unsigned?)
            (p/shell "/bin/chmod" "-R" "u+w" (str app))
            (when tainted?
              (p/shell "/usr/bin/xattr" "-d" "-r" "-s"
                       "com.apple.provenance" (str app)))
            (when unsigned?
              (p/shell "/usr/bin/codesign" "--force" "--deep" "--sign" "-" (str app))
              (p/shell "/usr/bin/codesign" "--verify" "--deep" "--strict" (str app)))))))))

;; Only ever repairs bundles the invoking user owns, so running this as anyone
;; else (sudo, another account) fails on the ownership checks rather than
;; needing the expected user passed in.
(defn sign-apps! [apps-dir]
  (let [apps-dir (fs/path apps-dir)]
    (cond
      (fs/sym-link? apps-dir)
      (fail! (str "Refusing to modify symlinked directory: " apps-dir))

      (not (fs/directory? apps-dir {:nofollow-links true}))
      nil

      :else
      (let [apps-owner (owner apps-dir)]
        (if (not= current-user apps-owner)
          (fail! (str "Refusing to modify " apps-dir " owned by " apps-owner))
          (doseq [app (fs/glob apps-dir "*.app")]
            (sign-app! app)))))))

(defn fails? [f]
  (try
    (f)
    false
    (catch Exception _ true)))

(defn selftest []
  (assert (provenance? "Fixture.app: com.apple.provenance"))
  (assert (provenance? "com.apple.provenance"))
  (assert (not (provenance? "Fixture.app: com.apple.quarantine")))

  (let [temp (fs/create-temp-dir {:prefix "sign-home-manager-apps-"})]
    (try
      (let [missing (fs/path temp "missing")
            target (fs/create-dir (fs/path temp "target"))
            root-link (fs/create-sym-link (fs/path temp "root-link") target)
            apps-dir (fs/create-dir (fs/path temp "apps"))
            app-link (fs/create-sym-link (fs/path apps-dir "Fixture.app") target)]
        (sign-apps! missing)
        (assert (fails? #(sign-apps! root-link)))
        (binding [*err* (java.io.StringWriter.)]
          (sign-apps! apps-dir))
        (assert (fs/sym-link? app-link)))
      (finally
        (fs/delete-tree temp))))

  (println "ok"))

(try
  (let [[argument :as args] *command-line-args*]
    (cond
      (= ["selftest"] args) (selftest)
      (= 1 (count args)) (sign-apps! argument)
      :else (do
              (warn! "usage: darwin-sign-apps <apps-dir> | selftest")
              (System/exit 2))))
  (catch Exception error
    (warn! (ex-message error))
    (System/exit 1)))
