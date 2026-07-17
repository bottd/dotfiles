# Glide pages

SvelteKit pages styled with UnoCSS and rendered by `@sveltejs/adapter-static`
for Glide to load through `file://`. JavaScript and CSS are inlined into each
page so client-side Svelte continues to work without a local web server.

The Nix build generates UnoCSS colors `base00` through `base0F` from the active
Stylix theme. `stylix-palette.json` provides the default Everforest dark palette
when running the development server outside Home Manager.

```sh
pnpm install
pnpm dev
pnpm check
pnpm build
```

Add pages as normal SvelteKit routes under `src/routes`. The root route is the
Glide new-tab page. Home Manager builds the project and links it to
`~/.local/share/glide-pages`.
