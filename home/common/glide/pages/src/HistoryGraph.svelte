<script lang="ts">
  import ForceGraph3D, {
    type ConfigOptions,
    type ForceGraph3DInstance,
    type LinkObject,
    type NodeObject,
  } from "3d-force-graph";
  import { onMount } from "svelte";
  import {
    CSS2DObject,
    CSS2DRenderer,
  } from "three/examples/jsm/renderers/CSS2DRenderer.js";
  import type { HistoryGraph, HistoryLink, HistorySite } from "./history";
  import {
    faviconMissing,
    faviconUrl,
    markFaviconMissing,
  } from "./site.svelte";

  type SiteNode = NodeObject & HistorySite;
  type ClickLink = LinkObject<SiteNode> & Pick<HistoryLink, "clicks">;

  // The default export's generics sit on the interface, not `new`; restate
  // the constructor with this graph's node and link shapes.
  const SiteGraph = ForceGraph3D as unknown as new (
    element: HTMLElement,
    options?: ConfigOptions,
  ) => ForceGraph3DInstance<SiteNode, ClickLink>;

  let { graph, visible }: { graph: HistoryGraph; visible: boolean } = $props();

  let container = $state() as HTMLDivElement;
  let webgl = $state(true);
  let graph3d: ForceGraph3DInstance<SiteNode, ClickLink> | undefined;

  const totalPages = $derived(
    graph.sites.reduce((sum, site) => sum + site.pages, 0),
  );
  const count = new Intl.NumberFormat();

  function cssVar(name: string) {
    return getComputedStyle(container).getPropertyValue(name).trim();
  }

  // Links name their ends by id until the layout swaps in the node objects.
  function endId(end: ClickLink["source"]) {
    return typeof end === "object" ? end.id : end;
  }

  // Favicon tiles are HTML (CSS2D) rather than WebGL sprites: most sites
  // send no CORS headers, so their icons can't become textures. They're the
  // page's .press-tile, so a missing icon becomes the same letter tile.
  function siteTile(site: SiteNode) {
    const size = Math.round(Math.min(44, 14 + 3 * Math.log2(site.pages)));
    const tile = document.createElement("div");
    tile.className = "press-tile site-tile";
    tile.style.setProperty("--size", `${size}px`);

    const showLetter = () => {
      tile.classList.add("press-letter");
      tile.textContent = site.id[0];
    };
    if (faviconMissing(site.id)) {
      showLetter();
    } else {
      const icon = document.createElement("img");
      icon.alt = "";
      icon.src = faviconUrl(site.id);
      icon.onerror = () => {
        markFaviconMissing(site.id);
        showLetter();
      };
      tile.append(icon);
    }
    return new CSS2DObject(tile);
  }

  // Same lifecycle as drake.dev's graph: created once, laid out before the
  // first frame, and resized with its container.
  onMount(() => {
    const probe = document.createElement("canvas");
    if (!probe.getContext("webgl2") && !probe.getContext("webgl")) {
      webgl = false;
      return;
    }

    // --press-rule is too close to paper for 1px lines; muted ink reads.
    const linkInk = cssVar("--press-muted");
    const plate = cssVar("--press-plate");
    let hovered: string | undefined;
    let fitted = false;

    const touchesHovered = (link: ClickLink) =>
      hovered !== undefined &&
      (endId(link.source) === hovered || endId(link.target) === hovered);

    const created = new SiteGraph(container, {
      extraRenderers: [new CSS2DRenderer()],
    })
      .showNavInfo(false)
      .backgroundColor("rgba(0,0,0,0)")
      .warmupTicks(100)
      .cooldownTime(3000)
      .nodeLabel(
        (node) =>
          `${node.id} · ${count.format(node.pages)} page${node.pages === 1 ? "" : "s"}`,
      )
      .nodeVal((node) => node.pages)
      .nodeRelSize(2)
      // The sphere stays for hover and click picking; the tile is what shows.
      .nodeOpacity(0)
      .nodeThreeObject(siteTile)
      .nodeThreeObjectExtend(true)
      .linkColor((link) => (touchesHovered(link) ? plate : linkInk))
      .linkWidth((link) => Math.min(3, 0.5 + Math.log2(link.clicks)))
      .linkDirectionalArrowLength(3)
      .linkDirectionalArrowRelPos(1)
      .onNodeHover((node) => {
        hovered = node ? String(node.id) : undefined;
        container.style.cursor = node ? "pointer" : "";
        created.linkColor(created.linkColor());
      })
      .onNodeClick((node) => {
        window.location.href = `https://${node.id}/`;
      })
      .onEngineStop(() => {
        if (fitted) return;
        fitted = true;
        // Fitting measures node spheres, not tiles; pad for the largest tile.
        created.zoomToFit(400, 80);
      })
      .graphData({
        nodes: graph.sites.map((site) => ({ ...site })),
        links: graph.links.map((link) => ({ ...link })),
      });

    // Tiles keep their screen size at any zoom, so spread the layout out
    // further than the default for spheres.
    created.d3Force("charge")?.strength(-400);
    created.d3Force("link")?.distance(140);
    graph3d = created;

    // Hidden views measure 0×0; keep the last real size until shown again.
    const observer = new ResizeObserver(() => {
      const { clientWidth, clientHeight } = container;
      if (clientWidth && clientHeight) {
        created.width(clientWidth).height(clientHeight);
      }
    });
    observer.observe(container);

    return () => {
      observer.disconnect();
      created._destructor();
    };
  });

  // The graph stays mounted while another view shows; stop its render loop
  // meanwhile instead of drawing frames nobody sees. Declared after onMount,
  // so the graph exists by its first run; it tracks only `visible`.
  $effect(() => {
    if (visible) graph3d?.resumeAnimation();
    else graph3d?.pauseAnimation();
  });
</script>

<div class="history">
  <p class="press-kicker history-meta">
    Last {graph.days} days · {count.format(graph.sites.length)} sites · {count.format(
      totalPages,
    )} pages
  </p>
  {#if webgl}
    <div class="graph" bind:this={container}></div>
    <p class="press-kicker history-hint">
      Drag to turn · Scroll to zoom · Click a site
    </p>
  {:else}
    <p class="press-empty">This browser has WebGL turned off.</p>
  {/if}
</div>

<style>
  .history {
    position: relative;
    block-size: 100%;
    min-block-size: 0;
    overflow: hidden;
  }

  .graph {
    position: absolute;
    inset: 0;
  }

  .history-meta,
  .history-hint {
    position: absolute;
    z-index: 1;
    inset-inline-start: var(--press-inset);
    margin: 0;
    pointer-events: none;
  }

  .history-meta {
    inset-block-start: var(--press-gap);
  }

  .history-hint {
    inset-block-end: var(--press-gap);
  }

  /* Graph tiles get an ink keyline; the tile itself is .press-tile. */
  .history :global(.site-tile) {
    border: var(--press-rule-width) solid var(--press-ink);
  }

  .history :global(.site-tile img) {
    inline-size: 100%;
    block-size: 100%;
    object-fit: contain;
  }

  /* The hover label is a caption tag: paper type reversed out of ink. */
  .history :global(.float-tooltip-kap) {
    padding: 6px 8px;
    border-radius: 0;
    background: var(--press-ink);
    color: var(--press-paper);
    font:
      var(--press-caption-size) / 1.25 var(--press-font),
      monospace;
  }
</style>
