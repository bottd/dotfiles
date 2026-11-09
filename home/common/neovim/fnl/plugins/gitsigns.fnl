(local gitsigns (require :gitsigns))
(import-macros {: binds : group} :macro.binds)

(gitsigns.setup {})

;; A text object, so operator-pending and visual only: `binds` registers in
;; normal mode, where an `ih` map makes `i` wait out timeoutlen.
(vim.keymap.set [:o :x] :ih #(gitsigns.select_hunk) {:desc "Select hunk"})

(binds [(group "Git hunks" :<leader>h
               [[:s #(gitsigns.stage_hunk) "Stage hunk"]
                [:r #(gitsigns.reset_hunk) "Reset hunk"]
                [:S #(gitsigns.stage_buffer) "Stage buffer"]
                [:R #(gitsigns.reset_buffer) "Reset buffer"]
                [:p #(gitsigns.preview_hunk) "Preview hunk"]
                [:i #(gitsigns.preview_hunk_inline) "Preview hunk inline"]
                [:b #(gitsigns.blame_line {:full true}) "Blame line"]
                [:d #(gitsigns.diffthis) "Diff this"]
                [:D #(gitsigns.diffthis "~") "Diff this ~"]
                [:Q #(gitsigns.setqflist :all) "All hunks to quickfix"]
                [:q #(gitsigns.setqflist) "Hunks to quickfix"]])])
