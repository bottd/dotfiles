(local pairs (require :blink.pairs))

; native lib comes from nixpkgs (see neovim/default.nix); download() can't run
; on a lux install since it needs a git checkout
(pairs.setup {})
