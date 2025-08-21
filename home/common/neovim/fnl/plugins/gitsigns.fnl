(local wk (require :which-key))
(local gitsigns (require :gitsigns))

(gitsigns.setup {})

(wk.add [{1 :ih 2 gitsigns.select_hunk :desc "Select hunk" :mode [:o :x]}
         {1 :<leader>h :group "Git hunks"}
         {1 :<leader>hs 2 gitsigns.stage_hunk :desc "Stage hunk"}
         {1 :<leader>hr 2 gitsigns.reset_hunk :desc "Reset hunk"}
         {1 :<leader>hs
          2 #(gitsigns.stage_hunk [(vim.fn.line ".") (vim.fn.line :v)])
          :desc "Stage hunk"
          :mode :v}
         {1 :<leader>hr
          2 #(gitsigns.reset_hunk [(vim.fn.line ".") (vim.fn.line :v)])
          :desc "Reset hunk"
          :mode :v}
         {1 :<leader>hS 2 gitsigns.stage_buffer :desc "Stage buffer"}
         {1 :<leader>hR 2 gitsigns.reset_buffer :desc "Reset buffer"}
         {1 :<leader>hp 2 gitsigns.preview_hunk :desc "Preview hunk"}
         {1 :<leader>hi
          2 gitsigns.preview_hunk_inline
          :desc "Preview hunk inline"}
         {1 :<leader>hb
          2 #(gitsigns.blame_line {:full true})
          :desc "Blame line"}
         {1 :<leader>hd 2 gitsigns.diffthis :desc "Diff this"}
         {1 :<leader>hD 2 #(gitsigns.diffthis "~") :desc "Diff this ~"}
         {1 :<leader>hQ
          2 #(gitsigns.setqflist :all)
          :desc "All hunks to quickfix"}
         {1 :<leader>hq 2 gitsigns.setqflist :desc "Hunks to quickfix"}])
