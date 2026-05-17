# scripts

Standalone helpers wired into home-manager via per-host `.nix` modules. Look at
the consumer module for context on each script:

- `quote-pack.clj` — dispatcher to `bb` tasks in the Quote-MC pack repo.
  Consumed by `home/linux/quote/launcher.nix` (the `quote-mc-launch` wrapper
  also exports `QUOTE_PACK_ROOT` so subshells resolve the same pack dir).
- `npm-clean-install.clj`, `rebuild.clj`, `tresorit-install.clj` — see
  `scripts/default.nix` for how each is exposed.
