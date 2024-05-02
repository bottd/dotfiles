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
}
