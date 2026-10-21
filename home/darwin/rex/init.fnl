;; Rex config: https://www.superlogical.com/rex/docs/customize/config
;; Validate with `rex config check`, apply with `rex config reload`.

(rex.bind :cmd+d :pane.split {:direction :right})
(rex.bind :cmd+shift+d :pane.split {:direction :down})
(rex.bind :cmd+shift+enter :pane.zoom)
