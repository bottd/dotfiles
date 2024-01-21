(local workspace (os.getenv :NEORG_WORKSPACE))
(local workspace_path (os.getenv :NEORG_WORKSPACE_PATH))
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
                [workspace] workspace_path
                :inbox (.. workspace_path "/inbox")
                :journals (.. workspace_path "/journals")
                :meta (.. workspace_path "/meta")
                :notes (.. workspace_path "/notes")
                :resources (.. workspace_path "/resources")
                :scripts (.. workspace_path "/scripts")
                :zettel (.. workspace_path "/zettel")
              }
              :default_workspace workspace
            }
          }
          :core.esupports.metagen {
            :config {
              :type "auto"
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
          :core.integrations.zen_mode {}
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
      2 ":Neorg journal today<Cr>"
      :desc "Journal"
    }
    {
      :mode "n"
      1 "<leader>nj"
      2 ":Neorg journal"
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
      1 "<leader>nr"
      2 ":Neorg return<Cr>"
      :desc "Neorg"
    }
  ]
}
