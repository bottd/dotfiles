import { defineConfig, presetWind3 } from "unocss";
import stylixPalette from "./stylix-palette.json" with { type: "json" };

export default defineConfig({
  presets: [presetWind3()],
  theme: {
    colors: stylixPalette,
  },
});
