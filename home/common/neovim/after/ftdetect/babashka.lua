-- Set .bb files to use clojure filetype and treesitter
-- .lua, not .fnl: nvim only sources ftdetect/*.{vim,lua}
vim.filetype.add({ extension = { bb = "clojure" } })
