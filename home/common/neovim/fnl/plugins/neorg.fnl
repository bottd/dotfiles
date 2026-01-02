(local neorg (require :neorg))
(local wk (require :which-key))
(local workspace (os.getenv :NEORG_WORKSPACE))
(local workspace_path (os.getenv :NEORG_WORKSPACE_PATH))

(local workspaces [:archive
                   :ideas
                   :inbox
                   :journals
                   :meta
                   :notes
                   :public
                   :resources
                   :scripts
                   :zettel])

(fn setup_template_autoload []
  (each [_ ws (ipairs workspaces)]
    (vim.api.nvim_create_autocmd [:BufNewFile :BufReadPost]
                                 {:pattern (.. workspace_path "/" ws
                                               :/**/*.norg)
                                  ":desc" (.. "Autoload template for " ws)
                                  :callback (fn []
                                              (vim.schedule (fn []
                                                              (local lines
                                                                     (vim.api.nvim_buf_get_lines 0
                                                                                                 0
                                                                                                 -1
                                                                                                 false))
                                                              (local is_empty
                                                                     (or (= (length lines)
                                                                            0)
                                                                         (and (= (length lines)
                                                                                 1)
                                                                              (= (. lines
                                                                                    1)
                                                                                 ""))))
                                                              (when (and is_empty
                                                                         (= vim.bo.buftype
                                                                            ""))
                                                                (local template_path
                                                                       (.. workspace_path
                                                                           :/meta/templates/
                                                                           ws
                                                                           :.norg))
                                                                (local fallback_template
                                                                       (.. workspace_path
                                                                           :/meta/templates/index.norg))
                                                                (cond (= (vim.fn.filereadable template_path)
                                                                         1)
                                                                      (vim.cmd (.. "Neorg templates fload "
                                                                                   ws))
                                                                      (= (vim.fn.filereadable fallback_template)
                                                                         1)
                                                                      (vim.cmd "Neorg templates fload index"))))))})))

(neorg.setup {:load {:core.defaults {}
                     :core.concealer {}
                     :core.completion {:config {:engine {:module_name :external.lsp-completion}
                                                :name "[Norg]"}}
                     :core.dirman {:config {:workspaces ((fn []
                                                           (local config
                                                                  {workspace workspace_path})
                                                           (each [_ ws (ipairs workspaces)]
                                                             (tset config ws
                                                                   (.. workspace_path
                                                                       "/" ws)))
                                                           config))
                                            :default_workspace workspace}}
                     :core.esupports.metagen {:config {:type :auto
                                                       :template [[:title
                                                                   (fn []
                                                                     (-> (vim.fn.expand "%:p:t:r")
                                                                         (: :gsub
                                                                            "-"
                                                                            " ")
                                                                         (: :gsub
                                                                            "(%a)([%w_']*)"
                                                                            (fn [first
                                                                                 rest]
                                                                              (.. (first:upper)
                                                                                  (rest:lower))))))]
                                                                  [:authors
                                                                   "Drake Bott"]
                                                                  [:created]
                                                                  [:updated]
                                                                  [:version]]}}
                     :core.export {}
                     :core.export.markdown {:config {:extensions :all}}
                     :core.integrations.treesitter {}
                     :core.itero {}
                     :core.journal {:config {:journal_folder :daily
                                             :template_name :meta/templates/journals.norg
                                             :strategy :flat
                                             :workspace :journals}}
                     :core.summary {}
                     :core.tangle {}
                     :external.archive {}
                     ; :external.query {}
                     :external.templates {:config {:templates_dir (.. workspace_path
                                                                      :/meta/templates)}}
                     :external.interim-ls {:config {:completion_provider {:enable true
                                                                          :categories false}}}
                     :external.worklog {:config {:default_workspace_title :external}}}})

(vim.keymap.set :n :<leader>j
                (fn []
                  (local journal_path
                         (.. workspace_path :/journals/daily/
                             (os.date "%Y-%m-%d") :.norg))
                  (Snacks.win {:width 0.6
                               :height 0.8
                               :border :rounded
                               :title "Daily Journal"
                               :title_pos :center
                               :file journal_path
                               :enter true
                               :bo {:modifiable true :readonly false}}))
                {:desc :Journal})

(wk.add [{1 :<leader>nj 2 ":Neorg journal<Cr>" :desc :Journal :icon " "}
         {1 :<leader>n<space> 2 ":Neorg index<Cr>" :desc :Index :icon " "}
         {1 :<leader>na :desc :Archive :icon " "}
         {1 :<leader>naf
          2 ":Neorg archive archive-file<Cr>"
          :desc "Archive file"
          :icon " "}
         {1 :<leader>nar
          2 ":Neorg archive restore-file<Cr>"
          :desc "Restore file"
          :icon " "}
         {1 :<leader>nt 2 ":Neorg tangle<Cr>" :desc :tangle}
         {1 :<leader>ne :desc :Export}
         {1 :<leader>nef 2 ":Neorg export to-file<Cr>" :desc "Export file"}
         {1 :<leader>ned
          2 ":Neorg export directory<Cr>"
          :desc "Export directory"}
         {1 :<leader>nep
          2 (.. ":Neorg export directory " workspace_path "/public md<Cr>")
          :desc "Export posts"}
         ; {1 :<leader>nq 2 ":Neorg query run<Cr>" :desc "Run Queries"}
         {1 :<leader>n :desc :Neorg :icon " "}])

;; (setup_template_autoload)
