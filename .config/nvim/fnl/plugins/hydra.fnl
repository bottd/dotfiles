(let [
  hydra (require :hydra)
  splits (require :smart-splits)
  cmd (. (require :hydra.keymap-util) :cmd)
  pcmd (. (require :hydra.keymap-util) :pcmd)
  ;window_hint (lua [[
  ;  "^^^^^^^^^^^^     Move      ^^    Size   ^^   ^^     Split"
  ;  "^^^^^^^^^^^^-------------  ^^-----------^^   ^^---------------"
  ;  "^ ^ _k_ ^ ^  ^ ^ _K_ ^ ^   ^   _<C-k>_   ^   _s_: horizontally"
  ;  "_h_ ^ ^ _l_  _H_ ^ ^ _L_   _<C-h>_ _<C-l>_   _v_: vertically"
  ;  "^ ^ _j_ ^ ^  ^ ^ _J_ ^ ^   ^   _<C-j>_   ^   _q_, _c_: close"
  ;  "focus^^^^^^  window^^^^^^  ^_=_: equalize^   _z_: maximize"
  ;  "^ ^ ^ ^ ^ ^  ^ ^ ^ ^ ^ ^   ^^ ^          ^   _o_: remain only"
  ;  "_b_: choose buffer"
  ;  "_t_: open terminal buffer"
  ;]])
  ]
  (hydra {
    :name "Windows"
    :hint window_hint
    :config {
      :invoke_on_body true
      :hint {
        :float_opts {
          :border "rounded"
        }
        :offset -1
      }
    }
    :mode "n"
    :body "<C-w>"
    :heads [
      [:h :<C-w>h]
      [:j :<C-w>j]
      [:k (pcmd "wincmd k" :E11 :close)]
      [:l :<C-w>l]
      [:H (cmd "WinShift left")]
      [:J (cmd "WinShift down")]
      [:K (cmd "WinShift up")]
      [:L (cmd "WinShift right")]
      [:<C-h> (fn [] (splits.resize_left 2))]
      [:<C-j> (fn [] (splits.resize_down 2))]
      [:<C-k> (fn [] (splits.resize_up 2))]
      [:<C-l> (fn [] (splits.resize_right 2))]
      [:= :<C-w>= { :desc "equalize"}]
      [:s (pcmd :split :E36)]
      [:<C-s> (pcmd :split :E36) { :desc false }]
      [:v (pcmd :vsplit :E36)]
      [:<C-v> (pcmd :vsplit :E36) { :desc false }]
      [:w :<C-w>w { :exit true :desc false }]
      [:<C-w> :<C-w>w { :exit true :desc false }]
      [:z (cmd :WindowsMaximaze) { :exit true :desc "maximize" }]
      [:<C-z> (cmd :WindowsMaximaze) { :exit true :desc false }]
      [:o :<C-w>o { :exit true :desc "remain only"}]
      [:<C-o> :<C-w>o { :exit true :desc false }]
      [:b choose_buffer { :exit true :desc "choose buffer" }]
      [:t (fn [] (vim.fn.termopen))]
      [:c (pcmd :close :E444)]
      [:q (pcmd :close :E444) { :desc "close window" }]
      [:<C-c> (pcmd :close :E444) { :desc false }]
      [:<C-q> (pcmd :close :E444) { :desc false }]
      [:<Esc> nil  { :exit true :desc false}]
    ]}))
