local wk = require("which-key")
local workspace = os.getenv("NEORG_WORKSPACE")
local workspace_path = os.getenv("NEORG_WORKSPACE_PATH")

local workspaces = {
	"archive",
	"inbox",
	"journals",
	"meta",
	"notes",
	"public",
	"resources",
	"scripts",
	"zettel",
}

local function setup_template_autoload()
	for _, ws in ipairs(workspaces) do
		vim.api.nvim_create_autocmd({ "BufNewFile", "BufReadPost" }, {
			pattern = workspace_path .. "/" .. ws .. "/**/*.norg",
			desc = "Autoload template for " .. ws,
			callback = function()
				vim.schedule(function()
					local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
					local is_empty = #lines == 0 or (#lines == 1 and lines[1] == "")
					if vim.bo.buftype == "" and is_empty then
						local template_path = workspace_path .. "/meta/templates/" .. ws .. ".norg"
						local fallback_template = workspace_path .. "/meta/templates/index.norg"

						if vim.fn.filereadable(template_path) == 1 then
							vim.cmd("Neorg templates fload " .. ws)
						elseif vim.fn.filereadable(fallback_template) == 1 then
							vim.cmd("Neorg templates fload index")
						end
					end
				end)
			end,
		})
	end
end

require("neorg").setup({
	load = {
		["core.defaults"] = {},
		["core.concealer"] = {},
		["core.completion"] = {
			config = {
				engine = { module_name = "external.lsp-completion" },
				name = "[Norg]",
			},
		},
		["core.dirman"] = {
			config = {
				workspaces = (function()
					local config = { [workspace] = workspace_path }
					for _, ws in ipairs(workspaces) do
						config[ws] = workspace_path .. "/" .. ws
					end
					return config
				end)(),
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
							return vim.fn.expand("%:p:t:r"):gsub("-", " "):gsub("(%a)([%w_']*)", function(first, rest)
								return first:upper() .. rest:lower()
							end)
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
				template_name = "meta/templates/journals.norg",
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
			config = { templates_dir = workspace_path .. "/meta/templates" },
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
		["external.neorg-dew"] = {},
		["external.dew-transclude"] = {
			config = {
				block_end_marker = "===",
				no_title = false,
			},
		},
	},
})

vim.keymap.set("n", "<leader>j", function()
	local journal_path = workspace_path .. "/journals/daily/" .. os.date("%Y-%m-%d") .. ".norg"

	Snacks.win({
		width = 0.6,
		height = 0.8,
		border = "rounded",
		title = "Daily Journal",
		title_pos = "center",
		file = journal_path,
		enter = true,
		bo = { modifiable = true, readonly = false },
	})
end, { desc = "Journal" })

wk.add({
	{ "<leader>nj", ":Neorg journal<Cr>", desc = "Journal", icon = " " },
	{ "<leader>n<space>", ":Neorg index<Cr>", desc = "Index", icon = " " },
	{ "<leader>na", desc = "Archive", icon = " " },
	{ "<leader>naf", ":Neorg archive archive-file<Cr>", desc = "Archive file", icon = " " },
	{ "<leader>nar", ":Neorg archive restore-file<Cr>", desc = "Restore file", icon = " " },
	{ "<leader>nt", ":Neorg tangle<Cr>", desc = "tangle" },
	{ "<leader>ne", desc = "Export" },
	{ "<leader>nef", ":Neorg export to-file<Cr>", desc = "Export file" },
	{ "<leader>ned", ":Neorg export directory<Cr>", desc = "Export directory" },
	{ "<leader>nep", ":Neorg export directory " .. workspace_path .. "/public md<Cr>", desc = "Export posts" },
	{ "<leader>nq", ":Neorg query run<Cr>", desc = "Run Queries" },
	{ "<leader>n", desc = "Neorg", icon = " " },
})

setup_template_autoload()
