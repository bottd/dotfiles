# Glide pages

A standalone Svelte page styled with UnoCSS. Vite inlines its JavaScript and CSS
so Glide can load it through `file://` without a local web server.

The Nix build generates UnoCSS colors `base00` through `base0F` from the active
Stylix theme. `stylix-palette.json` provides the default Everforest dark palette
when running the development server outside Home Manager.

```sh
pnpm install
pnpm dev
pnpm check
pnpm build
```

Home Manager builds the page and links it to `~/.local/share/glide-pages`.
