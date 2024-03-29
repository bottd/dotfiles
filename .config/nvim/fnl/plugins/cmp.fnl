{
  1 :hrsh7th/nvim-cmp
  :event "InsertEnter"
  :dependencies [
    :hrsh7th/cmp-nvim-lsp
    :hrsh7th/cmp-buffer
    :hrsh7th/cmp-path
    :hrsh7th/cmp-cmdline
    :L3MON4D3/LuaSnip
    :rafamadriz/friendly-snippets
    :f3fora/cmp-spell
    :Olical/conjure
    {
      1 :windwp/nvim-autopairs
      :event "InsertEnter"
    }
    {
      1 :zbirenbaum/copilot.lua
      :cmd "Copilot"
      :event "InsertEnter"
      :config (fn []
        ((. (require :copilot) :setup) {
          :suggestion { :enabled false }
          :panel { :enabled false }
         }))
    }
    {
      1 :zbirenbaum/copilot-cmp
      ;; :after ["copilot.lua"]
      :config (fn []
        ((. (require :copilot_cmp) :setup) {
          :method "getCompletionsCycling"
        }))
    }
  ]
  :config (fn []
    ;; Here is where you configure the autocompletion settings.
    (let [
      lsp_zero (require :lsp-zero)
      cmp (require :cmp)
      cmp_action (lsp_zero.cmp_action)
      cmp_autopairs (require :nvim-autopairs.completion.cmp)
    ]

    (lsp_zero.extend_cmp)
    (cmp.event:on :confirm_done (cmp_autopairs.on_confirm_done))
    (cmp.setup {
      :formatting (lsp_zero.cmp_format)
      :mapping (cmp.mapping.preset.insert {
        :<C-Space> (cmp.mapping.complete)
        :<C-u> (cmp.mapping.scroll_docs -4)
        :<C-d> (cmp.mapping.scroll_docs 4)
        :<C-f> (cmp_action.luasnip_jump_forward)
        :<C-b> (cmp_action.luasnip_jump_backward)
        ;; Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
        :<CR> (cmp.mapping.confirm { :select true })
      })
      :sources (cmp.config.sources [
        { :name "copilot" }
        { :name "nvim_lsp" }
        { :name "conjure" }
        { :name "path" }
        { :name "luasnip" }
        { :name "buffer" }
        ;; enable spell complete in md,norg, etc?
        ;; { :name "spell" }
        { :name "neorg" }
      ])
    })))
}
