local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local conf = require("telescope.config").values
local neorg_loaded, neorg = pcall(require, "neorg.core")
local make_entry = require("telescope.make_entry")
assert(neorg_loaded, "Neorg is not loaded - please make sure to load Neorg first")

local function get_zettel_files()
  local dirman = neorg.modules.get_module("core.dirman")

  if not dirman then
    return nil
  end

  local workspace = dirman.get_workspace("zettel")
  local files = dirman.get_norg_files("zettel")

  return { workspace, files }
end

local zettel = function(opts)
  opts = opts or {}

  local files = get_zettel_files()

  if not (files and files[2]) then
    return
  end

  opts.entry_maker = opts.entry_maker or make_entry.gen_from_file(opts)

  pickers
  .new(opts, {
    prompt_title = opts.prompt_title or "Find Zettel Files",
    cwd = files[1],
    finder = finders.new_table({
      results = files[2],
      entry_maker = make_entry.gen_from_file({ cwd = files[1] }),
    }),
    previewer = conf.file_previewer(opts),
    sorter = conf.file_sorter(opts),
  })
  :find()
end

-- write a function that sorts alphanumeric strings properly
-- 1a, 1b, 1c, 2a, 2b, 2c, 10a, 10b, 10c
local alphanum_sort = function(items)
  items = items or {}
  items = vim.tbl_map(function(item)
    local num = string.match(item, "%d+")
    local letter = string.match(item, "%a+")
    return { num = tonumber(num), letter = letter }
  end, items)
  return items
end

-- to execute the function
zettel()
