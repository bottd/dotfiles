(local {: get_sorted_zettel} (require :../zk))
(local workspace (os.getenv :NEORG_WORKSPACE))
(local workspace_path (os.getenv :NEORG_WORKSPACE_PATH))
(local {: setup} (require :neorg))
(setup {:load {:core.defaults {}
               :core.concealer {:config {}}
               :core.completion {:config {:engine :nvim-cmp :name "[Norg]"}}
               :core.dirman {:config {:workspaces {workspace workspace_path
                                                   :Inbox (.. workspace_path
                                                              :/inbox)
                                                   :Journals (.. workspace_path
                                                                 :/journals)
                                                   :Meta (.. workspace_path
                                                             :/meta)
                                                   :Notes (.. workspace_path
                                                              :/notes)
                                                   :Public (.. workspace_path
                                                               :/public)
                                                   :Resources (.. workspace_path
                                                                  :/resources)
                                                   :Scripts (.. workspace_path
                                                                :/scripts)
                                                   :Zettel (.. workspace_path
                                                               :/zettel)}
                                      :default_workspace workspace}}
               :core.export {}
               :core.export.markdown {:config {:extensions :all}}
               :core.integrations.telescope {}
               :core.integrations.nvim-cmp {}
               :core.integrations.treesitter {}
               :core.itero {}
               :core.journal {:config {:journal_folder :daily
                                       :template_name :meta/templates/journal.norg
                                       :strategy :flat
                                       :workspace :Journals}}
               :core.summary {}
               :core.tangle {}
               :external.context {}
               :external.templates {:config {:templates_dir (.. workspace_path
                                                                :/meta/templates)}}
               :external.worklog {:config {:default_workspace_title :External}}}})

(vim.keymap.set :n :<leader>j
                (fn []
                  (let [win_width (math.floor (* vim.o.columns 0.6))
                        win_height (math.floor (* vim.o.lines 0.8))
                        buf (vim.api.nvim_create_buf true false)]
                    (vim.api.nvim_open_win buf true
                                           {:width win_width
                                            :height win_height
                                            :row (/ (- vim.o.lines win_height)
                                                    2)
                                            :col (/ (- vim.o.columns win_width)
                                                    2)
                                            :relative :editor
                                            :border :rounded
                                            :title "Daily Journal"
                                            :title_pos :center}))
                  (vim.api.nvim_command ":Neorg journal today"))
                {:desc :Journal})

(vim.keymap.set :n :<leader>nj ":Neorg journal<Cr>" {:desc :Journal})

(vim.keymap.set :n :<leader>ni ":Neorg index<Cr>" {:desc :Index})

(vim.keymap.set :n :<leader>nmi ":Neorg inject-metadata<Cr>"
                {:desc "Inject Metadata"})

(vim.keymap.set :n :<leader>nf ":Telescope neorg find_norg_files<Cr>"
                {:desc "Find Norg"})

(vim.keymap.set :n :<leader>nt ":Neorg tangle<Cr>" {:desc ":Neorg tangle"})

(vim.keymap.set :n :<leader>nef ":Neorg export to-file" {:desc "Export file"})

(vim.keymap.set :n :<leader>ned ":Neorg export directory"
                {:desc "Export directory"})

(vim.keymap.set :n :<leader>nep
                (.. ":Neorg export directory " workspace_path "/public md<Cr>")
                {:desc "Export posts"})

(vim.keymap.set :n :<leader>nr ":Neorg return<Cr>" {:desc :Neorg})

(vim.keymap.set :n :<leader>nz get_sorted_zettel {:desc "Get Zettels"})

(let [which-key (require :which-key)]
  (which-key.add [{1 :<leader>n :desc :Neorg}]))

