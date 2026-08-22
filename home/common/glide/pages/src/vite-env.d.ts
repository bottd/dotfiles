/// <reference types="vite/client" />

declare module "virtual:uno.css";

declare namespace svelteHTML {
  import type { AttributifyAttributes } from "unocss/preset-attributify";

  type HTMLAttributes = AttributifyAttributes;
}
