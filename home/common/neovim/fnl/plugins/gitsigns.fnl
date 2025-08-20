(local wk (require "which-key"))
(local gitsigns (require "gitsigns"))

(gitsigns.setup {})

(wk.add {
	{ 
  0 "ih"  
  0 gitsigns.select_hunk  
  :desc "Select hunk"  :mode [ "o"  "x" ] 
  }
	{ 
    0 "<leader>h" :group "Git hunks" 
  }
	{ 
    0 "<leader>hs" 0 gitsigns.stage_hunk :desc "Stage hunk" 
  }
	{ 
    0 "<leader>hr" 0 gitsigns.reset_hunk :desc "Reset hunk" }
	{
		0 "<leader>hs"
		0 (fn []
			(gitsigns.stage_hunk [(vim.fn.line ".") (vim.fn.line "v")]))
		:desc "Stage hunk"
		:mode "v"
	}
	{
		0 "<leader>hr"
		0 (fn []
			(gitsigns.reset_hunk [(vim.fn.line ".") (vim.fn.line "v") ]))
		:desc "Reset hunk"
		:mode "v"
	}
	{ 0 "<leader>hS" 0 gitsigns.stage_buffer :desc "Stage buffer" }
	{ 0 "<leader>hR" 0 gitsigns.reset_buffer :desc "Reset buffer" }
	{ 0 "<leader>hp" 0 gitsigns.preview_hunk :desc "Preview hunk" }
	{ 0 "<leader>hi" 0 gitsigns.preview_hunk_inline :desc "Preview hunk inline" }
	{
		0 "<leader>hb"
		0 (fn []			(gitsigns.blame_line { :full true }))
		:desc "Blame line"
	}
	{ 0 "<leader>hd" 0 gitsigns.diffthis :desc "Diff this" }
	{
		0 "<leader>hD"
		0 (fn []
			(gitsigns.diffthis "~"))
		:desc "Diff this ~"
	}
	{
		0 "<leader>hQ"
		0 (fn []
			(gitsigns.setqflist "all"))
		:desc "All hunks to quickfix"
	}
	{ 0 "<leader>hq" 0 gitsigns.setqflist :desc "Hunks to quickfix" }
})
