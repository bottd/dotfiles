require('which-key').register({
  f = {
    name = "[F]ind",
    f = { ":Telescope find_files<Cr>", "[F]ind [F]ile" },
    s = { ":Telescope live_grep<Cr>", "[F]ind [S]tring" },
    k = { ":Telescope keymaps<Cr>", "[F]ind [K]eymap" },
    h = { ":Telescope help_tags<Cr>", "[F]ind [H]elp" },
  },
  u = { ":Telescope undo<Cr>", "[U]ndo tree" },
  r = { 
    r = { "<Plug>SnipRun<Cr>", "SnipRun Block"}
    o = { "<Plug>SnipRunOperator<Cr>", "SnipRun Operator"}
  },
}, { prefix = "<leader>" })
