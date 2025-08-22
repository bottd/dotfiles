(fn group [name prefix binds]
  "Helper macro for group syntax - just returns as-is for binds macro to process"
  `(group ,name ,prefix ,binds))

(fn binds [bindings]
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
  (var group-items [])
  (var regular-items [])
  (each [_ item (ipairs bindings)]
    (if (and (list? item) (= (tostring (. item 1)) :group))
        ;; Process group
        (let [[_ group-name prefix binds] item]
          (table.insert group-items `{1 ,prefix :group ,group-name})
          (each [_ bind (ipairs binds)]
            (let [[suffix action desc & rest] bind
                  full-key `(.. ,prefix ,suffix)]
              (if (= (length rest) 1)
                  (table.insert group-items
                                `{1 ,full-key
                                  2 ,action
                                  :desc ,desc
                                  :icon ,(. rest 1)})
                  (table.insert group-items
                                `{1 ,full-key 2 ,action :desc ,desc})))))
        ;; Process individual bind
        (let [[key action desc & rest] item]
          (if (= (length rest) 1)
              (table.insert regular-items
                            `{1 ,key 2 ,action :desc ,desc :icon ,(. rest 1)})
              (table.insert regular-items `{1 ,key 2 ,action :desc ,desc})))))
  (let [all-items []]
    (each [_ item (ipairs regular-items)]
      (table.insert all-items item))
    (each [_ item (ipairs group-items)]
      (table.insert all-items item))
    `(let [wk# (require :which-key)]
       (wk#.add [,(unpack all-items)]))))

{: binds : group}
