(local utils (require :theme.utils))
(local palette {
  :base "#232136"
  :overlay "#393552"
  :muted "#6e6a86"
  :text "#e0def4"
  :love "#eb6f92"
  :gold "#f6c177"
  :rose "#ea9a97"
  :pine "#3e8fb0"
  :foam "#9ccfd8"
  :iris "#c4a7e7"
  ;; highlight_high = "#56526e"
})
(local rose_pine_moon (utils.create_rose_pine_theme palette))
rose_pine_moon
