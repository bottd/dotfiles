local wk = require("which-key")
local workspace = os.getenv("NEORG_WORKSPACE")
local workspace_path = os.getenv("NEORG_WORKSPACE_PATH")
require("neorg").setup({
	load = {
		["core.defaults"] = {},
		["core.concealer"] = { config = {} },
		["core.completion"] = {
			config = {
				engine = {
					module_name = "external.lsp-completion",
				},
				name = "[Norg]",
			},
		},
		["core.dirman"] = {
			config = {
				workspaces = {
					[workspace] = workspace_path,
					archive = (workspace_path .. "/archive"),
					inbox = (workspace_path .. "/inbox"),
					journals = (workspace_path .. "/journals"),
					manuscripts = (workspace_path .. "/manuscripts"),
					meta = (workspace_path .. "/meta"),
					notes = (workspace_path .. "/notes"),
					public = (workspace_path .. "/public"),
					resources = (workspace_path .. "/resources"),
					scripts = (workspace_path .. "/scripts"),
					zettel = (workspace_path .. "/zettel"),
				},
				default_workspace = workspace,
			},
		},
		["core.esupports.metagen"] = {
			config = {
				type = "auto",
				template = {
					{
						"title",
						function()
							local filename = vim.fn.expand("%:p:t:r")
							filename = filename:gsub("-", " ")
							filename = filename:gsub("(%a)([%w_']*)", function(first, rest)
								return (first:upper() .. rest:lower())
							end)
							return filename
						end,
					},
					{ "authors", "Drake Bott" },
					{ "created" },
					{ "updated" },
					{ "version" },
				},
			},
		},
		["core.export"] = {},
		["core.export.markdown"] = { config = { extensions = "all" } },
		["core.integrations.treesitter"] = {},
		["core.itero"] = {},
		["core.journal"] = {
			config = {
				journal_folder = "daily",
				template_name = "meta/templates/journal.norg",
				strategy = "flat",
				workspace = "journals",
			},
		},
		["core.summary"] = {},
		["core.tangle"] = {},
		["external.archive"] = {},
		["external.context"] = {},
		["external.query"] = {},
		["external.templates"] = {
			config = {
				templates_dir = (workspace_path .. "/meta/templates"),
			},
		},
		["external.interim-ls"] = {
			config = {
				completion_provider = {
					enable = true,
					categories = false,
				},
			},
		},
		["external.worklog"] = {
			config = { default_workspace_title = "external" },
		},
	},
})
vim.keymap.set("n", "<leader>j", function()
	Snacks.win({
		width = 0.6,
		height = 0.8,
		border = "rounded",
		title = "Daily Journal",
		title_pos = "center",
	}, function(win)
		vim.api.nvim_command(":Neorg journal today")
	end)
end, { desc = "Journal" })

wk.add({
	{ "<leader>nj", ":Neorg journal<Cr>", desc = "Journal", icon = " " },
	{ "<leader>n<space>", ":Neorg index<Cr>", desc = "Index", icon = " " },
	{ "<leader>na", desc = "Archive", icon = " " },
	{ "<leader>naf", ":Neorg archive current-file<Cr>", desc = "Archive file", icon = " " },
	{ "<leader>nf", ":Telescope neorg find_norg_files<Cr>", desc = "Find Norg" },
	{ "<leader>nt", ":Neorg tangle<Cr>", desc = "tangle" },

	{ "<leader>ne", desc = "Export" },
	{ "<leader>nef", ":Neorg export to-file<Cr>", desc = "Export file" },
	{ "<leader>ned", ":Neorg export directory<Cr>", desc = "Export directory" },
	{
		"<leader>nep",
		":Neorg export directory " .. workspace_path .. "/public md<Cr>",
		desc = "Export posts",
	},
	{ "<leader>nq", ":Neorg query run<Cr>", desc = "Run Queries" },
	-- TODO: This icon will be neorg once my nerdfont (provided by ghostty) is updated
	{ "<leader>n", desc = "Neorg", icon = " " },
})
