(local indentscope (require :mini.indentscope))
(indentscope.setup {:symbol "│" :options {:try_as_border true}})

(local ibl (require :ibl))
(ibl.setup {:indent {:char "│"} :scope {:enabled false}})