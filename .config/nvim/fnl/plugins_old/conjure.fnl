{
    1 :Olical/conjure
    :ft [:fennel]
    :dependencies [
        { 1 :Olical/nfnl :ft "fennel" }
        {
            1 :PaterJason/cmp-conjure
            :config (fn []
              (let [
                cmp (require "cmp")
                config ((. cmp :get_config))
              ]
                (table.insert config.sources {
                  :name "buffer"
                    :option {
                      :sources [{ :name "conjure" }]
                    }
                })
                (cmp.setup config)
                ))
          }
    ]
    :config (fn []
        ((. (require :conjure.main) :main))
        ((. (require :conjure.mapping) :on-filetype))
    )
    :init (fn [] (set vim.g.conjure#debug true))
}
