(local whitelist {:Spotify true :Music true})

(local media (sbar.add :item {:icon {:drawing false}
                              :position :center
                              :updates true}))

(media:subscribe :media_change
                 (fn [env]
                   (when (. whitelist env.INFO.app)
                     (media:set {:drawing (if (= env.INFO.state :playing)
                                              true
                                              false)
                                 :label (.. env.INFO.artist ": " env.INFO.title)}))))

