;; Rex config: https://www.superlogical.com/rex/docs/customize/config
;; Validate with `rex config check`, apply with `rex config reload`.

(rex.bind :cmd+d :pane.split {:direction :right})
(rex.bind :cmd+shift+d :pane.split {:direction :down})
(rex.bind :cmd+shift+enter :pane.zoom)

;; Command palette
(rex.bind :cmd+shift+p :client.palette.toggle)

;; Zellij-style tmux mode: Ctrl+a enters, any action drops back out (like
;; zellij's SwitchToMode after each tmux bind). Exclusive so stray keys
;; don't type into the terminal.
(rex.mode :tmux {:exclusive true})
(rex.bind :ctrl+a :client.mode.enter {:name :tmux :once true})
(rex.bind :tmux/ctrl+a :client.mode.exit)

(rex.bind "tmux/shift+'" :pane.split {:direction :down})

; "
(rex.bind :tmux/shift+5 :pane.split {:direction :right})

; %
(rex.bind :tmux/z :pane.zoom)
(rex.bind :tmux/x :pane.close)
(rex.bind :tmux/o :pane.focus_next)

(rex.bind :tmux/h :pane.focus.left)
(rex.bind :tmux/j :pane.focus.down)
(rex.bind :tmux/k :pane.focus.up)
(rex.bind :tmux/l :pane.focus.right)
(rex.bind :tmux/left :pane.focus.left)
(rex.bind :tmux/down :pane.focus.down)
(rex.bind :tmux/up :pane.focus.up)
(rex.bind :tmux/right :pane.focus.right)

(rex.bind :tmux/c :client.tab.new)
(rex.bind :tmux/n :client.tab.next)
(rex.bind :tmux/p :client.tab.previous)
(rex.bind "tmux/," :client.tab.rename)

;; Not in zellij's tmux mode, but handy behind the same prefix.
(rex.bind "tmux/shift+;" :client.palette.toggle)

; :

;; Zellij's Alt binds. Zellij's Alt+h/l fall through to the next tab at the
;; edge; Rex's pane.focus can't, so these only move between panes.
(rex.bind :alt+n :pane.split.auto)
(rex.bind :alt+h :pane.focus.left)
(rex.bind :alt+j :pane.focus.down)
(rex.bind :alt+k :pane.focus.up)
(rex.bind :alt+l :pane.focus.right)
(rex.bind :alt+left :pane.focus.left)
(rex.bind :alt+down :pane.focus.down)
(rex.bind :alt+up :pane.focus.up)
(rex.bind :alt+right :pane.focus.right)
(rex.bind :alt+i :client.tab.move.backward)
(rex.bind :alt+o :client.tab.move.forward)

;; Resize mode: Ctrl+a r enters, hjkl resizes (shift for bigger steps),
;; Esc or Enter leaves.
(rex.mode :resize {:exclusive true})
(rex.bind :tmux/r :client.mode.enter {:name :resize})
(rex.bind :resize/h :pane.resize {:direction :left})
(rex.bind :resize/j :pane.resize {:direction :down})
(rex.bind :resize/k :pane.resize {:direction :up})
(rex.bind :resize/l :pane.resize {:direction :right})
(rex.bind :resize/shift+h :pane.resize {:direction :left :amount 15})
(rex.bind :resize/shift+j :pane.resize {:direction :down :amount 15})
(rex.bind :resize/shift+k :pane.resize {:direction :up :amount 15})
(rex.bind :resize/shift+l :pane.resize {:direction :right :amount 15})
(rex.bind :resize/= :pane.balance)
(rex.bind :resize/enter :client.mode.exit)
