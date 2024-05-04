(let [
  cmp (require "cmp")
  config ((. cmp :get_config))
]
  (table.insert config.sources {
    :name "buffer"
      :option {
        :sources [{ :name "conjure" }]
      }})
  (cmp.setup config))

((. (require :conjure.main) :main))
((. (require :conjure.mapping) :on-filetype))
