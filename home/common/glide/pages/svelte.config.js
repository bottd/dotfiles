import adapter from "@sveltejs/adapter-static";
import { vitePreprocess } from "@sveltejs/vite-plugin-svelte";

/** @type {import('@sveltejs/kit').Config} */
const config = {
  preprocess: [vitePreprocess()],
  kit: {
    adapter: adapter({
      pages: "build",
      assets: "build",
      strict: true,
    }),
    output: {
      // Inline scripts and styles so pages work when opened through file://.
      bundleStrategy: "inline",
    },
    paths: {
      relative: true,
    },
  },
};

export default config;
