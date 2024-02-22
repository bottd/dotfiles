(local {: an-compare } (require :alphanum))

(fn open_zettel []
  (var neorg (require :neorg))
  (var dirman (neorg.modules.get_module :core.dirman))
  (var line (vim.api.nvim_get_current_line))
  (dirman.open_file :zettel line))

(fn get_sorted_zettel []
  (var neorg (require :neorg))
  (var dirman (neorg.modules.get_module :core.dirman))
  (var files (dirman.get_norg_files :zettel))
  (table.sort files an-compare)
  (let [
     ed_width (vim.fn.winwidth :%)
     ed_height (vim.fn.winwidth :%)
     win_width (math.floor (* ed_width 0.6))
     win_height (math.floor (* ed_height 0.8))
     buf (vim.api.nvim_create_buf true true)
    ]
      (vim.cmd :vsplit)
      (vim.api.nvim_buf_set_lines buf 0 -1 true files)
      (vim.api.nvim_buf_set_name buf :zettels)
      (vim.api.nvim_win_set_buf (vim.api.nvim_get_current_win) buf)
      (vim.api.nvim_buf_set_keymap buf :n "<Cr>" "" { :callback open_zettel })
  ))

{ :get_sorted_zettel get_sorted_zettel }
