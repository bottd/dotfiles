(local which-key (require :which-key))
(local splits (require :smart-splits))
; for now using Folke default, hydra mode on <c-w><space>, would like to have <c-w> be recursive but this errors out
(which-key.add [{1 :<C-w><space>
                 2 (fn [] (which-key.show {:keys :<C-w> :loop true}))}
                ; {1 :<C-w>H 2 "<Cd>WinShift left<CR>" :desc "Shift left"}
                ; {1 :<C-w>J 2 "<Cmd>WinShift down<CR>" :desc "Shift down"}
                ; {1 :<C-w>K 2 "<Cmd>WinShift up<CR>" :desc "Shift down"}
                ; {1 :<C-w>L 2 "<Cmd>WinShift right<CR>" :desc "Shift down"}
                ; {1 :<C-w><C-h>
                ;  2 (fn [] (splits.resize_left 2))
                ;  :desc "Resize left"}
                ; {1 :<C-w><C-j>
                ;  2 (fn [] (splits.resize_down 2))
                ;  :desc "Resize down"}
                ; {1 :<C-w><C-k>
                ;  2 (fn [] (splits.resize_up 2))
                ;  :desc "Resize up"}
                ; {1 :<C-w><C-l>
                ;  2 (fn [] (splits.resize_right 2))
                ;  :desc "Resize right"}
                ; {1 :<C-w>= :desc :Equalize}
                ; {1 :<C-w>s 2 "<Cmd>:split<cr>" :desc :Split}
                ; {1 :<C-w>v 2 "<Cmd>:vsplit<cr>" :desc :Vsplit}
                ; {1 :<C-w>q 2 "<Cmd>:close<cr>" :desc :Close}
                ; {1 :<C-w>z 2 "<Cmd>:WindowsMaximize<cr>" :desc :Maximize}
                ; {1 :<C-w>o 2 :<C-w>o :desc "Only window"}
                ; {1 :<C-w>t 2 (fn [] (vim.fn.termopen)) :desc "Open term"}
                {1 :<leader>w
                 :group :windows
                 :proxy :<c-w>
                 :expand (fn []
                           (local {: expand} (require :which-key.extras))
                           (expand.win))}])

