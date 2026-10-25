# Glide pages

A standalone Svelte page styled with plain CSS. Vite inlines its JavaScript and
CSS so Glide can load it through `file://` without a local web server.

Colors are the custom properties `--base00` through `--base0F` in
`src/palette.css`. The committed file is the Everforest dark palette for the
development server; the Nix build overwrites it with the active Stylix theme.

```sh
pnpm install
pnpm dev
pnpm check
pnpm build
```

Home Manager builds the page and links it to `~/.local/share/glide-pages`.
