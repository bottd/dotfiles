(local indentscope (require :mini.indentscope))
(local ibl (require :ibl))

(indentscope.setup {:symbol "│"
                    :options {:try_as_border true}
                    :animation (indentscope.gen_animation.linear {:easing :out
                                                                  :duration 20
                                                                  :unit :total})})

(ibl.setup {:indent {:char "│"}
            :scope {:enabled false}
            :exclude {:language [:fennel]}})
