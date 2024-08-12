(let [cmp (require :cmp)
      config ((. cmp :get_config))]
  (table.insert config.sources
                {:name :buffer :option {:sources [{:name :conjure}]}})
  (cmp.setup config))

(local {: main} (require :conjure.main))
(main)

(local {: on-filetype} (require :conjure.mapping))
(on-filetype)

(local which-key (require :which-key))
(which-key.add [{1 :<leader>e :desc "Evaluate [Conjure]"}
                {1 :<leader>l :desc "Log [Conjure]"}])

