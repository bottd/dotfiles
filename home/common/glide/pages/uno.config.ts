import { defineConfig, presetWind3 } from "unocss";
import stylixPalette from "./stylix-palette.json" with { type: "json" };

export default defineConfig({
  presets: [presetWind3()],
  shortcuts: {
    "hn-frame": "overflow-hidden rounded-[3px] shadow-xl",
    "hn-page":
      "min-h-0 border border-base03 bg-[#f6f6ef] font-[Verdana] text-[13px] text-black sm:min-h-[390px]",
    "hn-header":
      "flex min-h-6.75 items-center whitespace-nowrap bg-[#ff6600] p-0.5 [&_a]:text-black [&_a]:no-underline",
    "hn-logo":
      "mr-1.25 grid h-5 w-5 place-items-center border border-white font-sans text-[13px] !text-white",
    "hn-name": "mr-1.75 font-bold",
    "hn-content":
      "min-h-0 px-1.75 pb-1.25 pt-3 sm:min-h-[316px] sm:px-2 sm:pb-1.75 sm:pt-3.5",
    "story-list": "m-0 grid list-none gap-2.75 p-0 sm:gap-2.25",
    story: "grid grid-cols-[24px_minmax(0,1fr)]",
    rank: "pt-px text-right text-[#828282]",
    "story-main": "min-w-0",
    "story-heading":
      "flex min-w-0 items-start pl-1.25 leading-4 sm:items-baseline",
    votearrow:
      "mb-0.5 mr-1.25 h-0 w-0 flex-none border-b-8 border-l-5 border-r-5 border-b-[#828282] border-l-transparent border-r-transparent",
    "story-title":
      "min-w-0 whitespace-normal text-black no-underline visited:text-[#828282] sm:truncate sm:whitespace-nowrap",
    "story-host":
      "ml-1.25 hidden flex-auto truncate whitespace-nowrap text-[10px] text-[#828282] sm:block",
    "story-meta":
      "mb-0 ml-5 mt-0.5 text-[9px] leading-3 text-[#828282] [&_a]:text-inherit [&_a]:no-underline [&_a:hover]:underline",
    "story-loading": "min-h-7.5",
    "loading-block":
      "mt-0.75 block h-2.5 w-[min(78%,480px)] animate-pulse bg-[#e4e4dc]",
    "loading-meta":
      "mt-2 block h-1.75 w-[min(40%,230px)] animate-pulse bg-[#e4e4dc] opacity-70",
    "hn-state":
      "grid min-h-[280px] place-content-center justify-items-center text-[#828282]",
    "hn-retry":
      "cursor-pointer border-0 border-b border-[#828282] bg-transparent text-[11px] text-black",
    "hn-footer":
      "pb-4 pl-9.25 pr-3.5 pt-2 [&_a]:text-black [&_a]:no-underline [&_a:hover]:underline",
    widget: "rounded-[3px] shadow-xl",
    "media-links": "grid p-2",
    "media-link":
      "grid grid-cols-[48px_minmax(0,1fr)] items-start gap-3 rounded-0.5 px-2.5 py-3 text-inherit no-underline transition-colors duration-120 hover:bg-base02",
    "media-favicon":
      "h-12 w-12 rounded-1 border border-base03 bg-base00 object-contain p-2",
    "media-heading": "flex items-center justify-between gap-2",
    "media-name": "block text-[13px] font-medium text-base07",
    "media-description": "mt-1 block text-[10px] leading-3.5 text-base05",
    "media-details": "mt-1.5 flex items-center gap-1.5",
    "media-domain": "font-mono text-[9px] text-base04",
    "media-kind":
      "border border-base03 px-1.5 py-0.5 text-[8px] tracking-wide text-base04 uppercase",
    arrow: "text-xs text-base04",
  },
  theme: {
    colors: stylixPalette,
  },
});
