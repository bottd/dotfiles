import { defineConfig, presetWind3 } from "unocss";
import stylixPalette from "./stylix-palette.json" with { type: "json" };

export default defineConfig({
  presets: [presetWind3()],
  shortcuts: {
    "hn-frame": "overflow-hidden rounded-[3px] shadow-xl",
    "hn-page":
      "flex h-full min-h-0 flex-col border border-base03 bg-[#f6f6ef] text-[13px] text-black sm:min-h-[390px]",
    "hn-header":
      "flex min-h-7 items-center whitespace-nowrap bg-[#ff6600] p-0.5 [&_a]:text-black [&_a]:no-underline",
    "hn-logo":
      "mr-1.25 grid h-5 w-5 place-items-center border border-white text-[13px] !text-white",
    "hn-name": "mr-1.75 font-bold",
    "hn-content":
      "min-h-0 flex-1 px-1.75 pb-3 pt-3 sm:px-2 sm:pb-3.5 sm:pt-3.5",
    "story-list":
      "m-0 grid h-full content-between list-none gap-2.75 p-0 sm:gap-2.25",
    story: "grid grid-cols-[24px_minmax(0,1fr)]",
    rank: "pt-px text-right text-[#5f5f5f]",
    "story-main": "min-w-0",
    "story-heading":
      "flex min-w-0 items-start pl-1.25 leading-4 sm:items-baseline",
    "story-title":
      "min-w-0 whitespace-normal text-black no-underline visited:text-[#5f5f5f] focus-visible:outline-2 focus-visible:outline-[#005fcc] sm:truncate sm:whitespace-nowrap",
    "story-host":
      "ml-1.25 hidden flex-auto truncate whitespace-nowrap text-[11px] text-[#5f5f5f] sm:block",
    "story-meta":
      "mb-0 ml-1.25 mt-1 flex flex-wrap items-center gap-x-1.5 text-[11px] leading-4 text-[#5f5f5f] [&_a]:text-inherit [&_a]:underline-offset-2 [&_a:hover]:underline",
    "story-loading": "min-h-7.5",
    "loading-block":
      "mt-0.75 block h-2.5 w-[min(78%,480px)] animate-pulse bg-[#e4e4dc] motion-reduce:animate-none",
    "loading-meta":
      "mt-2 block h-1.75 w-[min(40%,230px)] animate-pulse bg-[#e4e4dc] opacity-70 motion-reduce:animate-none",
    "hn-state":
      "grid min-h-[280px] place-content-center justify-items-center text-[#5f5f5f]",
    "hn-retry":
      "cursor-pointer border-0 border-b border-[#5f5f5f] bg-transparent text-[11px] text-black focus-visible:outline-2 focus-visible:outline-[#005fcc]",
    "wiki-frame":
      "flex h-full min-w-0 flex-col overflow-hidden rounded-[3px] border border-[#a2a9b1] bg-white text-[#202122] shadow-xl",
    "wiki-header": "border-b border-[#c8ccd1] bg-[#f8f9fa] px-4 py-2.5",
    "wiki-brand":
      "flex min-w-0 items-center gap-2.5 text-[#202122] no-underline focus-visible:outline-2 focus-visible:outline-[#36c]",
    "wiki-mark":
      "grid h-10 w-10 flex-none place-items-center font-[Georgia] text-[34px] leading-none text-black",
    "wiki-wordmark":
      "m-0 truncate font-[Georgia] text-[20px] font-normal tracking-[0.02em] leading-5 text-black",
    "wiki-tagline":
      "mt-0.5 block truncate text-[9px] tracking-[0.08em] text-[#54595d]",
    "wiki-search": "border-b border-[#c8ccd1] bg-white p-3",
    "wiki-search-control":
      "flex min-w-0 border border-[#72777d] bg-white focus-within:border-[#36c] focus-within:ring-1 focus-within:ring-[#36c]",
    "wiki-search-input":
      "min-w-0 flex-1 border-0 bg-white px-2.5 py-1.75 text-[12px] text-[#202122] outline-none placeholder:text-[#72777d]",
    "wiki-search-button":
      "cursor-pointer border-0 border-l border-[#72777d] bg-[#f8f9fa] px-3 text-[11px] font-semibold text-[#202122] hover:bg-white focus-visible:outline-2 focus-visible:outline-[#36c] focus-visible:outline-offset--2",
    "wiki-nav":
      "flex flex-wrap gap-x-3 gap-y-1 border-b border-[#c8ccd1] bg-[#f8f9fa] px-3 py-2 text-[10px] [&_a]:text-[#36c] [&_a]:no-underline [&_a:hover]:underline",
    "wiki-feature":
      "m-3 flex flex-1 flex-col border border-[#a3bfb1] bg-[#f5fffa]",
    "wiki-feature-heading":
      "flex items-center justify-between border-b border-[#a3bfb1] bg-[#cef2e0] px-2.5 py-1 font-[Georgia] text-[14px] font-bold text-black [&_a]:grid [&_a]:h-4 [&_a]:w-4 [&_a]:place-items-center [&_a]:rounded-full [&_a]:border [&_a]:border-[#72777d] [&_a]:font-sans [&_a]:text-[10px] [&_a]:text-[#36c] [&_a]:no-underline",
    "wiki-feature-loading":
      "grid min-h-44 gap-3 p-3 lg:grid-cols-[112px_minmax(0,1fr)]",
    "wiki-feature-error":
      "grid min-h-44 place-content-center justify-items-center gap-3 p-4 text-center text-[11px] [&_p]:m-0 [&_button]:cursor-pointer [&_button]:border [&_button]:border-[#72777d] [&_button]:bg-[#f8f9fa] [&_button]:px-3 [&_button]:py-1.5 [&_button]:font-semibold [&_button]:text-[#202122] [&_button:hover]:bg-white",
    "wiki-article":
      "grid flex-1 content-start gap-3 p-3 text-[11px] leading-4 lg:grid-cols-[112px_minmax(0,1fr)]",
    "wiki-article-image":
      "h-28 overflow-hidden border border-[#c8ccd1] bg-white p-1 lg:h-24",
    "wiki-image-fallback":
      "grid h-full place-items-center bg-[#eaecf0] font-[Georgia] text-5xl text-[#54595d]",
    "wiki-article-title":
      "m-0 font-[Georgia] text-[15px] font-bold leading-4.5 [&_a]:text-[#36c] [&_a]:no-underline [&_a:hover]:underline",
    "wiki-article-description":
      "m-0 mt-1 line-clamp-2 text-[10px] italic text-[#54595d]",
    "wiki-article-extract":
      "m-0 mt-2 line-clamp-7 text-[#202122] lg:line-clamp-12",
    "wiki-read-more":
      "mt-2 inline-block text-[10px] text-[#36c] no-underline hover:underline",
    widget: "rounded-[3px] shadow-xl",
    "media-links": "grid p-2",
    "media-link":
      "grid grid-cols-[48px_minmax(0,1fr)] items-start gap-3 rounded-0.5 px-2.5 py-3 text-inherit no-underline transition-colors duration-120 hover:bg-base02 focus-visible:outline-2 focus-visible:outline-base0D focus-visible:outline-offset--2",
    "media-favicon":
      "h-12 w-12 rounded-1 border border-base03 bg-base00 object-contain p-2",
    "media-heading": "flex min-w-0 items-center justify-between gap-2",
    "media-name": "block min-w-0 truncate text-[13px] font-medium text-base07",
    "media-description": "mt-1 block truncate text-xs leading-4 text-base07",
    "media-details": "mt-1.5 flex min-w-0 items-center gap-1.5",
    "media-domain": "min-w-0 truncate font-mono text-[11px] text-base07",
    "media-kind":
      "flex-none border border-base0E px-1.5 py-0.5 text-[10px] tracking-wide text-base07 uppercase",
    arrow: "flex-none text-xs text-base0D",
  },
  theme: {
    colors: stylixPalette,
  },
});
