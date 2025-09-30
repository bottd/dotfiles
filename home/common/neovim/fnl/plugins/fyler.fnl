(local wk (require :which-key))
(local fyler (require :fyler))

(wk.add [{1 :<C-m> 2 #(fyler.open) :desc "Open Fyler"}])
