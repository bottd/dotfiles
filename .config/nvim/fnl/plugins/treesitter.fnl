{
  1 {
    1 :nvim-treesitter/nvim-treesitter
    :dependencies [
      :windwp/nvim-ts-autotag
      :nvim-treesitter/nvim-treesitter-context
    ]
    :build ":TSUpdate"
    :config (fn []
      (let [ts (require :nvim-treesitter.configs)]
      (ts.setup {
        :ensure_installed [
          :comment
          :css
          :diff
          :fennel
          :fish
          :gitignore
          :graphql
          :html
          :json
          :markdown
          :markdown_inline
          :norg
          :lua
          :python
          :rust
          :sql
          :svelte
          :toml
          :tsx
          :typescript
          :vimdoc
        ]
        :autotag {:enable true}
        :highlight {:enable true}
      })
    ))
  }
  2 {
    1 :numToStr/Comment.nvim
    :dependencies [
      :JoosepAlviste/nvim-ts-context-commentstring
      :nvim-treesitter/nvim-treesitter
    ]
    :config (fn []
      (let [comment-nvim (require :Comment)]
      (comment-nvim.setup {
        :pre_hook (fn []
          (let [ts-comment-integration (require :ts_context_commentstring.integrations.comment_nvim)]
          (ts-comment-integration.create_pre_hook)
       ))
      })
    ))
  }
}
