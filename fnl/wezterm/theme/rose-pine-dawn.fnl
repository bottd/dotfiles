(local utils (require :theme.utils))
(local palette {
  :base "#faf4ed"
  :overlay "#f2e9e1"
  :muted "#9893a5"
  :text "#575279"
  :love "#b4637a"
  :gold "#ea9d34"
  :rose "#d7827e"
  :pine "#286983"
  :foam "#56949f"
  :iris "#907aa9"
  ;;highlight_high "#cecacd"
})
(local rose_pine_dawn (utils.create_rose_pine_theme palette))
rose_pine_dawn
