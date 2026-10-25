# Glide pages

A standalone Svelte page styled with plain CSS. Vite inlines its JavaScript and
CSS so Glide can load it through `file://` without a local web server.

Colours, type sizes and spacing are the Dither Press `--press-*` custom
properties in `src/palette.css`. The committed file holds Everforest dark at
fontSize 12 for the development server; the Nix build overwrites it with the
tokens `home/common/glide/default.nix` generates from Stylix, which the browser
chrome (`config/press.css`) uses too.

The History view gets its data from `config/glide.ts`, so outside Glide it only
shows a message.

```sh
pnpm install
pnpm dev
pnpm check
pnpm build
```

Home Manager builds the page and links it to `~/.local/share/glide-pages`.
