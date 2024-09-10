(fn get-spaces []
  (local spaces [])
  (sbar.exec "aerospace list-workspaces --all"
             (fn [result]
               (set spaces
                    (for [i 1 (length result)]
                      (table.insert spaces (string.sub result i i))))))
  spaces)

;; (var workspaces (get-spaces))

(local bar-spaces (sbar.add :item {:position :left :label {:string :Yo1}}))

