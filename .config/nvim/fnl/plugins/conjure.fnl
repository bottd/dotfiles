(let [cmp (require :cmp)
      config ((. cmp :get_config))]
  (table.insert config.sources
                {:name :buffer :option {:sources [{:name :conjure}]}})
  (cmp.setup config))

((. (require :conjure.main) :main))
((. (require :conjure.mapping) :on-filetype))
(let [which-key (require :which-key)]
  (which-key.add [{1 :<leader>e :desc "Evaluate [Conjure]"}
                  {1 :<leader>l :desc "Log [Conjure]"}]))

