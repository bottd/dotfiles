(local {: get_sorted_zettel } (require :../zk))
(local workspace (os.getenv :NEORG_WORKSPACE))
(local workspace_path (os.getenv :NEORG_WORKSPACE_PATH))
[
  {
    1 :vhyrro/luarocks.nvim
    :branch "more-fixes"
    :config (fn []
              (let [luarocks (require :luarocks)]
                (luarocks.setup {})))
  }
  {
    1 :nvim-neorg/neorg
    :build ":Neorg sync-parsers"
    :dependencies [
      :MunifTanjim/nui.nvim
      :nvim-lua/plenary.nvim
      :nvim-neorg/neorg-telescope
      { 
        1 :pysan3/neorg-templates 
        :dependencies [:L3MON4D3/LuaSnip]
      }
      {
        1 :lukas-reineke/headlines.nvim
        :config true
      }
    ]
    :ft "norg"
    :config (fn []
      (let [neorg (require :neorg)]
        (neorg.setup {
          :load {
            :core.defaults {}
            :core.concealer { :config {} }
            :core.completion {
              :config {
                :engine "nvim-cmp"
                :name "[Norg]"
              }
            }
            :core.dirman {
              :config {
                :workspaces {
                  workspace workspace_path
                  :inbox (.. workspace_path "/inbox")
                  :journals (.. workspace_path "/journals")
                  :meta (.. workspace_path "/meta")
                  :notes (.. workspace_path "/notes")
                  :public (.. workspace_path "/public")
                  :resources (.. workspace_path "/resources")
                  :scripts (.. workspace_path "/scripts")
                  :zettel (.. workspace_path "/zettel")
                }
                :default_workspace workspace
              }
            }
            :core.export {}
            :core.export.markdown {
              :config {
                :extensions "all"
              }
            }
            :core.integrations.telescope {}
            :core.integrations.nvim-cmp {}
            :core.integrations.treesitter {}
            :core.itero {}
            :core.journal {
              :config {
                :journal_folder "daily"
                :template_name "meta/templates/journal.norg"
                :strategy "flat"
                :workspace "journals"
              }
            }
            :core.summary {}
            :core.tangle {}
            :external.templates {
              :config {
                :templates_dir (.. workspace_path "/meta/templates")
              }
            }
          }
        }
      )
    ))
    :keys [
      {
        :mode "n"
        1 "<leader>j"
        2 (fn []
            (let [
              win_width (math.floor (* vim.o.columns 0.6))
              win_height (math.floor (* vim.o.lines 0.8))
              buf (vim.api.nvim_create_buf true false)
            ]
            (vim.api.nvim_open_win buf true { 
               :width win_width
               :height win_height
               :row (/ (- vim.o.lines win_height) 2)
               :col (/ (- vim.o.columns win_width) 2)
               :relative "editor" 
               :border "rounded" 
               :title "Daily Journal"
               :title_pos "center"
            }))
          (vim.api.nvim_command ":Neorg journal today"))
        :desc "Journal"
      }
      {
        :mode "n"
        1 "<leader>nj"
        2 ":Neorg journal<Cr>"
        :desc "Journal"
      }
      {
        :mode "n"
        1 "<leader>ni"
        2 ":Neorg index<Cr>"
        :desc "Index"
      }
      {
        :mode "n"
        1 "<leader>nmi"
        2 ":Neorg inject-metadata<Cr>"
        :desc "Inject Metadata"
      }

      {
        :mode "n"
        1 "<leader>nf"
        2 ":Telescope neorg find_norg_files<Cr>"
        :desc "Find Norg"
      }
      {
        :mode "n"
        1 "<leader>nt"
        2 ":Neorg tangle<Cr>"
        :desc ":Neorg tangle"
      }
      {
        :mode "n"
        1 "<leader>nef"
        2 ":Neorg export to-file"
        :desc "Export file"
      }
      {
        :mode "n"
        1 "<leader>ned"
        2 ":Neorg export directory"
        :desc "Export directory"
      }
      {
        :mode "n"
        1 "<leader>nep"
        2 (.. ":Neorg export directory " workspace_path "/public md<Cr>")
        :desc "Export posts"
      }
      {
        :mode "n"
        1 "<leader>nr"
        2 ":Neorg return<Cr>"
        :desc "Neorg"
      }
      {
        :mode "n"
        1 "<leader>nz"
        2 get_sorted_zettel
        :desc "Get Zettels"
      }
    ]
  }
]
