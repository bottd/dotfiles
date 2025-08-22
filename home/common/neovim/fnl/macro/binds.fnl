(fn group [name prefix binds icon]
  "Helper macro for group syntax - just returns as-is for binds macro to process"
  (if icon
      `(group ,name ,prefix ,binds ,icon)
      `(group ,name ,prefix ,binds)))

(fn binds [items]
  "Register key bindings with which-key in an ergonomic syntax.

  (binds [bind1 bind2 ...])

  Bind: [key action desc icon?]
    - key: which key to bind to
    - action: vim command string or fennel function
    - desc: shown in which-key
    - icon: (optional) shown in which-key

  Group bind:
    (group name prefix binds icon?)
    - name: group display name
    - prefix: key prefix like :<leader>h
    - binds: list of [bind]
    - icon: (optional) shown in which-key

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
  (let [specs []]
    (each [_ item (ipairs items)]
      (if (and (list? item) (= (tostring (. item 1)) :group))
          ;; Process group - add group header then all group binds
          (let [[_ name prefix group-binds icon] item
                group-spec (if icon
                               `{1 ,prefix :group ,name :icon ,icon}
                               `{1 ,prefix :group ,name})]
            (table.insert specs group-spec)
            (each [_ [suffix action desc icon] (ipairs group-binds)]
              (let [full-key `(.. ,prefix ,suffix)
                    spec (if icon
                             `{1 ,full-key 2 ,action :desc ,desc :icon ,icon}
                             `{1 ,full-key 2 ,action :desc ,desc})]
                (table.insert specs spec))))
          ;; Process regular bind
          (let [[key action desc icon] item
                spec (if icon
                         `{1 ,key 2 ,action :desc ,desc :icon ,icon}
                         `{1 ,key 2 ,action :desc ,desc})]
            (table.insert specs spec))))
    `(let [wk# (require :which-key)]
       (wk#.add [,(unpack specs)]))))

{: binds : group}
