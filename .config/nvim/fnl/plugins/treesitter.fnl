(let [ts (require :nvim-treesitter.configs)]
  (ts.setup {
    :autotag {:enable true}
    :highlight {:enable true }}))
