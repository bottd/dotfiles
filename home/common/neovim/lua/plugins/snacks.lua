local snacks = require("snacks")
snacks.setup({
	bigfile = { enabled = true },
	dashboard = {
		enabled = true,
		sections = {
			{
				section = "terminal",
				cmd = "fortune -s | cowsay -f stegosaurus",
				hl = "header",
				height = 24,
				width = 68,
			},
			{ icon = " ", title = "Projects", section = "projects", indent = 2, padding = 1 },
			{ icon = " ", title = "Recent Files", section = "recent_files", indent = 2, padding = 1 },
		},
	},
	gitbrowse = { enabled = true },
	image = {
		enabled = true,
		doc = {
			enabled = true,
			inline = true,
			float = true,
			max_width = 80,
			max_height = 40,
		},
	},
	lazygit = { enabled = true },
	picker = {
		layout = {
			preset = "ivy_split",
		},
	},
	styles = {
		zen = { backdrop = { transparent = false } },
	},
	zen = { enabled = true },
	win = { enabled = true },
})

local wk = require("which-key")
wk.add({
	{
		"<leader>gg",
		function()
			Snacks.lazygit()
		end,
		desc = "Lazygit",
	},

	{
		"<leader>gw",
		function()
			Snacks.gitbrowse()
		end,
		desc = "Open in browser",
		icon = " ",
	},
	{
		"<leader>wz",
		function()
			Snacks.zen()
		end,
		desc = "Zen mode",
		icon = "󱅻 ",
	},
	{
		"<leader>f",
		group = "Find",
	},
	{
		"<leader>ff",
		function()
			Snacks.picker.files()
		end,
		desc = "Files",
	},
	{
		"<leader>fs",
		function()
			Snacks.picker.grep()
		end,
		desc = "String",
	},
	{
		"<leader>fb",
		function()
			Snacks.picker.buffers()
		end,
		desc = "Buffer",
	},
	{
		"<leader>fk",
		function()
			Snacks.picker.keymaps()
		end,
		desc = "Keymap",
	},
	{
		"<leader>fh",
		function()
			Snacks.picker.help()
		end,
		desc = "Help Pages",
	},
	{
		"<leader>fm",
		function()
			Snacks.picker.man()
		end,
		desc = "Man Pages",
	},
})
