(macro binds [...]
  "Register key bindings with which-key in an ergonomic syntax.

  (binds [bind1 bind2 ...])

  Bind: [key action desc icon]
    - key: declare which key to bind to
    - action: string for vim cmd or fennel function
    - desc: shown in which-key menu
    - icon: (optional) shown in which-key menu

  Group bind:
    (group name prefix binds)
    
    - name: Display name for the group (string)
    - prefix: Key prefix like :<leader>h
    - binds: List of [suffix action desc] or [suffix action desc icon]

  Examples:
    (binds [[:jj #(vim.cmd.stopinsert) \"Exit insert\"]
            [:ff #(find-files) \"Find files\"]
            (group \"Git hunks\" :<leader>h
                   [[:s #(stage-hunk) \"Stage\"]
                    [:r #(reset-hunk) \"Reset\"]])])

  This expands a wich-key add call:

  local which-key = require('which-key')
  which-key.add({
    { 'jj', function() vim.cmd.stopinsert() end, desc = 'Exit insert' },
    { 'ff', function() find-files() end, desc = 'Find files' },
    { '<leader>h', group = 'Git hunks' },
    { '<leader>hs', function() stage-hunk() end, desc = 'Stage' },
    { '<leader>hr', function() reset-hunk() end, desc = 'Reset' },
  })
  "
  (let [all-binds (icollect [_ item (ipairs [...])]
                    (if (and (list? item) (= (tostring (. item 1)) :group))
                        ;; Process group
                        (let [(_ group-name prefix binds) item
                              group-entry `{1 ,prefix :group ,group-name}
                              group-binds (icollect [_ bind (ipairs binds)]
                                            (let [full-key `(.. ,prefix
                                                                ,(. bind 1))]
                                              (match bind
                                                [suffix action desc] `{1 ,full-key
                                                                       2 ,action
                                                                       :desc ,desc}
                                                [suffix action desc icon] `{1 ,full-key
                                                                            2 ,action
                                                                            :desc ,desc
                                                                            :icon ,icon})))]
                          (values group-entry (unpack group-binds)))
                        ;; Process individual bind
                        (match item
                          [key action desc] `{1 ,key 2 ,action :desc ,desc}
                          [key action desc icon] `{1 ,key
                                                   2 ,action
                                                   :desc ,desc
                                                   :icon ,icon})))]
    `(let [wk# (require :which-key)]
       (wk#.add [,(unpack all-binds)]))))
