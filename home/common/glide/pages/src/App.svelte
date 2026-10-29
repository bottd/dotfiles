<script lang="ts">
  import { onMount } from "svelte";
  import {
    historyMessage,
    type HistoryGraph as HistoryGraphData,
  } from "./history";
  import {
    faviconMissing,
    faviconUrl,
    markFaviconMissing,
    siteHost,
  } from "./site.svelte";
  import { store, stored } from "./storage";

  type HackerNewsStory = {
    by: string;
    descendants?: number;
    id: number;
    score: number;
    time: number;
    title: string;
    url?: string;
  };

  type AstronomyPicture = {
    copyright?: string;
    date: string;
    explanation: string;
    image: string;
    link: string;
    title: string;
    video: boolean;
  };

  // A science.nasa.gov WordPress post; the explanation and credit are only
  // in its rendered page body.
  type AstronomyPicturePost = {
    content: { rendered: string };
    date: string;
    featured_image_url?: string;
    link: string;
    title: { rendered: string };
  };

  type WikipediaArticle = {
    content_urls: {
      desktop: { page: string };
    };
    description?: string;
    extract: string;
    thumbnail?: {
      source: string;
    };
    title: string;
  };

  type KickLivestream = {
    is_live: boolean;
    session_title: string;
    viewer_count: number;
  };

  const hackerNewsApi = "https://hacker-news.firebaseio.com/v0";
  const hackerNewsStoryCount = 10;
  // APOD moved to science.nasa.gov, whose REST API allows file:// origins;
  // api.nasa.gov's shared DEMO_KEY is almost always over its rate limit.
  // Category 22766 is APOD.
  const astronomyPictureApi =
    "https://science.nasa.gov/wp-json/wp/v2/image-article?categories=22766&per_page=1&_fields=content,date,featured_image_url,link,title";
  type Site = {
    href: string;
    title: string;
    description: string;
    kickChannel?: string;
  };

  function withHost(site: Site) {
    const hostname = siteHost(site.href);
    return { ...site, hostname, favicon: faviconUrl(hostname) };
  }

  const mediaSites: Site[] = [
    {
      href: "https://youtube.com/",
      title: "YouTube",
      description: "Videos, music, subscriptions, and live streams.",
    },
    {
      href: "https://destiny.gg/",
      title: "Destiny",
      description: "Livestreams, debates, events, and the DGG community.",
      kickChannel: "destiny",
    },
    {
      href: "https://apnews.com/",
      title: "AP News",
      description:
        "Independent reporting and breaking news from around the world.",
    },
  ];
  const personalSites: Site[] = [
    {
      href: "https://drena.haus/",
      title: "Drena Haus",
      description: "Shared home dashboard, mostly media.",
    },
    {
      href: "https://git.drake.bot/",
      title: "Forge",
      description: "Private git forge.",
    },
    {
      href: "https://a.drake.dev/",
      title: "Analytics",
      description: "Private analytics dashboard.",
    },
  ];
  const linkGroups = [
    { id: "media", title: "Media", sites: mediaSites.map(withHost) },
    { id: "personal", title: "Personal", sites: personalSites.map(withHost) },
  ];

  let stories: HackerNewsStory[] = [];
  let loading = true;
  let error = false;
  let wikipediaArticle: WikipediaArticle | undefined;
  let wikipediaArticleLoading = true;
  let wikipediaArticleError = false;
  let astronomyPicture: AstronomyPicture | undefined;
  let astronomyPictureLoading = true;
  let astronomyPictureError = false;
  let livestreams: Record<string, KickLivestream> = {};

  // The big views share the bottom panel; the last one shown is remembered.
  const views = [
    { id: "apod", title: "Picture of the day" },
    { id: "history", title: "History" },
  ] as const;
  type ViewId = (typeof views)[number]["id"];
  const viewKey = "big-view";
  const savedView = stored(viewKey);
  let view: ViewId =
    views.find(({ id }) => id === savedView)?.id ?? views[0].id;
  // History is only read, and the graph's code only loaded, once its view is
  // first shown; after that the graph stays mounted.
  let historyShown = false;
  let historyGraph: HistoryGraphData | undefined;

  // glide.ts watches this attribute and answers with a historyMessage.
  function requestHistory() {
    if (historyShown) return;
    historyShown = true;
    document.documentElement.dataset.historyWanted = "true";
  }

  function showView(next: ViewId) {
    view = next;
    store(viewKey, next);
    if (next === "history") requestHistory();
  }

  function viewKeydown(event: KeyboardEvent) {
    const step = { ArrowLeft: -1, ArrowRight: 1 }[event.key];
    if (!step) return;
    const index = views.findIndex(({ id }) => id === view);
    const next = views[(index + step + views.length) % views.length];
    showView(next.id);
    document.getElementById(`view-tab-${next.id}`)?.focus();
  }

  function receiveHistory(event: MessageEvent) {
    if (event.data?.type === historyMessage) historyGraph = event.data.graph;
  }

  function storyUrl(story: HackerNewsStory) {
    return story.url ?? `https://news.ycombinator.com/item?id=${story.id}`;
  }

  function storyHost(story: HackerNewsStory) {
    return story.url ? siteHost(story.url) : "news.ycombinator.com";
  }

  function storyAge(timestamp: number) {
    const seconds = Math.max(1, Math.floor(Date.now() / 1000 - timestamp));
    const intervals = [
      ["day", 86_400],
      ["hour", 3_600],
      ["minute", 60],
    ] as const;

    for (const [unit, duration] of intervals) {
      if (seconds >= duration) {
        const amount = Math.floor(seconds / duration);
        return `${amount} ${unit}${amount === 1 ? "" : "s"} ago`;
      }
    }

    return `${seconds} second${seconds === 1 ? "" : "s"} ago`;
  }

  function localDate() {
    const date = new Date();
    const month = String(date.getMonth() + 1).padStart(2, "0");
    const day = String(date.getDate()).padStart(2, "0");
    return `${date.getFullYear()}-${month}-${day}`;
  }

  async function loadStories() {
    loading = true;
    error = false;
    const signal = AbortSignal.timeout(10_000);

    try {
      const topResponse = await fetch(`${hackerNewsApi}/topstories.json`, {
        signal,
      });
      if (!topResponse.ok) throw new Error("Could not load Hacker News");

      const ids = (await topResponse.json()) as number[];
      const loadedStories = await Promise.all(
        ids.slice(0, hackerNewsStoryCount).map(async (id) => {
          const response = await fetch(`${hackerNewsApi}/item/${id}.json`, {
            signal,
          });
          return response.ok
            ? ((await response.json()) as HackerNewsStory)
            : undefined;
        }),
      );
      stories = loadedStories.filter((story): story is HackerNewsStory =>
        Boolean(story),
      );
      if (stories.length === 0)
        throw new Error("Could not load Hacker News stories");
    } catch {
      error = true;
    } finally {
      loading = false;
    }
  }

  function wikipediaArticleTitle(article: WikipediaArticle) {
    return article.title.replaceAll("_", " ");
  }

  async function loadWikipediaArticle() {
    wikipediaArticleLoading = true;
    wikipediaArticleError = false;
    const date = localDate();
    const cacheKey = "wikipedia-featured";
    const signal = AbortSignal.timeout(10_000);

    try {
      const cached = stored(cacheKey);
      if (cached) {
        const { date: cachedDate, article } = JSON.parse(cached) as {
          date: string;
          article: WikipediaArticle;
        };
        if (
          cachedDate === date &&
          article.title &&
          article.extract &&
          article.content_urls.desktop.page
        ) {
          wikipediaArticle = article;
          wikipediaArticleLoading = false;
          return;
        }
      }
    } catch {
      // Fetch a fresh copy when the cached one doesn't parse.
    }

    try {
      const response = await fetch(
        `https://api.wikimedia.org/feed/v1/wikipedia/en/featured/${date.replaceAll("-", "/")}`,
        { signal },
      );
      if (!response.ok)
        throw new Error("Could not load Wikipedia's featured article");

      const { tfa: article } = (await response.json()) as {
        tfa?: WikipediaArticle;
      };
      if (
        !article?.title ||
        !article.extract ||
        !article.content_urls.desktop.page
      ) {
        throw new Error("Wikipedia did not provide a featured article");
      }

      wikipediaArticle = article;
      store(cacheKey, JSON.stringify({ date, article }));
    } catch {
      wikipediaArticleError = true;
    } finally {
      wikipediaArticleLoading = false;
    }
  }

  // featured_image_url carries the original's size as resize parameters; the
  // backdrop asks NASA's resizer for a screen-sized copy instead.
  function astronomyPictureUrl(picture: AstronomyPicture) {
    const url = new URL(picture.image);
    url.search = "?w=1920";
    return url.href;
  }

  function astronomyPictureTarget(picture: AstronomyPicture) {
    if (picture.video) return picture.link;
    const url = new URL(picture.image);
    url.search = "";
    return url.href;
  }

  function astronomyPictureFromPost(
    post: AstronomyPicturePost,
  ): AstronomyPicture | undefined {
    if (!post.featured_image_url) return;
    const page = new DOMParser().parseFromString(
      post.content.rendered,
      "text/html",
    );
    const text = (element: Element | null | undefined) =>
      element?.textContent?.replace(/\s+/g, " ").trim() ?? "";

    const explanation = text(
      page.querySelector(".media-detail-hero__description"),
    ).replace(/^Explanation:\s*/, "");
    const credit = [
      ...page.querySelectorAll(".media-detail-hero__meta-row"),
    ].find((row) => text(row.querySelector("th")).startsWith("Credit"));
    // "APOD: 29 October 2026 – The Horns of Venus"
    const title = text(
      new DOMParser().parseFromString(post.title.rendered, "text/html").body,
    ).replace(/^APOD:[^–]*–\s*/, "");

    return {
      copyright: text(credit?.querySelector("td")) || undefined,
      date: post.date.slice(0, 10),
      explanation,
      image: post.featured_image_url,
      link: post.link,
      title,
      video:
        page.querySelector(".media-detail-hero__media :is(video, iframe)") !==
        null,
    };
  }

  function astronomyPictureDate(date: string) {
    return new Date(`${date}T00:00:00`).toLocaleDateString(undefined, {
      month: "long",
      day: "numeric",
      year: "numeric",
    });
  }

  async function loadAstronomyPicture() {
    astronomyPictureLoading = true;
    astronomyPictureError = false;
    const date = localDate();
    const cacheKey = "nasa-apod";
    const signal = AbortSignal.timeout(10_000);

    try {
      const cached = stored(cacheKey);
      if (cached) {
        const { date: cachedDate, picture } = JSON.parse(cached) as {
          date: string;
          picture: AstronomyPicture;
        };
        if (cachedDate === date && picture.image) {
          astronomyPicture = picture;
          astronomyPictureLoading = false;
          return;
        }
      }
    } catch {
      // Fetch a fresh copy when the cached one doesn't parse.
    }

    try {
      const response = await fetch(astronomyPictureApi, { signal });
      if (!response.ok) throw new Error("Could not load NASA APOD");

      const [post] = (await response.json()) as AstronomyPicturePost[];
      const picture = post && astronomyPictureFromPost(post);
      if (!picture) throw new Error("NASA APOD did not provide an image");

      astronomyPicture = picture;
      store(cacheKey, JSON.stringify({ date, picture }));
    } catch {
      astronomyPictureError = true;
    } finally {
      astronomyPictureLoading = false;
    }
  }

  // Kick allows cross-origin reads from file://; destiny.gg's own API does not.
  async function loadLivestream(channel: string) {
    try {
      const response = await fetch(
        `https://kick.com/api/v2/channels/${channel}`,
        { signal: AbortSignal.timeout(10_000) },
      );
      if (!response.ok) return;

      const { livestream } = (await response.json()) as {
        livestream: KickLivestream | null;
      };
      if (livestream?.is_live) {
        livestreams = { ...livestreams, [channel]: livestream };
      }
    } catch {
      // Offline and unreachable look the same: no indicator.
    }
  }

  const viewerCount = new Intl.NumberFormat(undefined, {
    notation: "compact",
    maximumFractionDigits: 1,
  });

  // The bar's halftone seam (quickshell/modules/DitherSeam.qml), as a CSS
  // mask tile: the same 16-step order and row stagger, with each row's
  // coverage taken at its centre, sized from the --press-seam-* tokens.
  // The page's stylesheet is already in place when this runs, so the tile is
  // built once, before the first paint.
  const seam = (() => {
    const order = [0, 8, 2, 10, 12, 4, 14, 6, 3, 11, 1, 9, 15, 7, 13, 5];
    const tokens = getComputedStyle(document.documentElement);
    const cell = parseInt(tokens.getPropertyValue("--press-seam-cell"));
    const height = parseInt(tokens.getPropertyValue("--press-seam-height"));
    const rows = Math.max(1, Math.ceil(height / cell));
    const columns = order.length;
    const cells = [];
    for (let row = 0; row < rows; ++row) {
      const coverage = (row + 0.5) / rows;
      for (let column = 0; column < columns; ++column) {
        const threshold = (order[(column + row * 5) % columns] + 0.5) / columns;
        if (threshold < coverage) {
          cells.push(
            `<rect x="${column * cell}" y="${row * cell}" width="${cell}" height="${cell}"/>`,
          );
        }
      }
    }
    const svg = `<svg xmlns="http://www.w3.org/2000/svg" width="${columns * cell}" height="${rows * cell}" shape-rendering="crispEdges">${cells.join("")}</svg>`;
    return `url("data:image/svg+xml,${encodeURIComponent(svg)}") 0 0 / ${columns * cell}px ${rows * cell}px repeat-x`;
  })();

  onMount(() => {
    mediaSites.forEach(
      ({ kickChannel }) => kickChannel && loadLivestream(kickChannel),
    );
    loadStories();
    loadWikipediaArticle();
    loadAstronomyPicture();

    window.addEventListener("message", receiveHistory);
    if (view === "history") requestHistory();
    return () => window.removeEventListener("message", receiveHistory);
  });
</script>

<main class="page">
  <div class="shell">
    <h1 class="sr-only">New tab</h1>
    <div class="columns">
      <section
        class="card hn"
        aria-labelledby="hacker-news-title"
        aria-busy={loading}
      >
        <header class="hn-header">
          <a
            class="hn-logo"
            href="https://news.ycombinator.com/"
            aria-label="Hacker News home">Y</a
          >
          <h2>
            <a
              class="hn-name"
              id="hacker-news-title"
              href="https://news.ycombinator.com/"
            >
              Hacker News
            </a>
          </h2>
        </header>

        <div class="sr-only" role="status">
          {loading
            ? "Loading top Hacker News stories"
            : error
              ? "Hacker News could not be reached"
              : `${stories.length} top Hacker News stories loaded`}
        </div>
        <div class="hn-content">
          {#if loading}
            <ol class="story-list" aria-hidden="true">
              {#each Array(hackerNewsStoryCount) as _, index}
                <li class="story story-loading">
                  <span class="rank">{index + 1}.</span>
                  <div class="story-main">
                    <span class="loading-title"></span>
                    <span class="loading-meta"></span>
                  </div>
                </li>
              {/each}
            </ol>
          {:else if error}
            <div class="hn-state">
              <p>Hacker News could not be reached.</p>
              <button class="hn-retry" type="button" onclick={loadStories}
                >try again</button
              >
            </div>
          {:else}
            <ol class="story-list" aria-label="Top Hacker News stories">
              {#each stories as story, index (story.id)}
                <li class="story">
                  <span class="rank">{index + 1}.</span>
                  <div class="story-main">
                    <div class="story-heading">
                      <a class="story-title" href={storyUrl(story)}
                        >{story.title}</a
                      >
                      {#if storyHost(story)}
                        <span class="story-host truncate"
                          >({storyHost(story)})</span
                        >
                      {/if}
                    </div>
                    <p class="story-meta">
                      {story.score} points by
                      <a
                        href={`https://news.ycombinator.com/user?id=${story.by}`}
                        >{story.by}</a
                      >
                      <a
                        href={`https://news.ycombinator.com/item?id=${story.id}`}
                      >
                        {storyAge(story.time)}
                      </a>
                      <span>|</span>
                      <a
                        href={`https://news.ycombinator.com/item?id=${story.id}`}
                      >
                        {story.descendants ?? 0} comments
                      </a>
                    </p>
                  </div>
                </li>
              {/each}
            </ol>
          {/if}
        </div>
      </section>

      <section
        class="card wiki"
        aria-labelledby="wiki-title"
        aria-busy={wikipediaArticleLoading}
      >
        <header class="wiki-header">
          <a class="wiki-brand" href="https://en.wikipedia.org/wiki/Main_Page">
            <span class="wiki-mark" aria-hidden="true">W</span>
            <span class="wiki-brand-text">
              <h2 id="wiki-title" class="wiki-wordmark truncate">Wikipedia</h2>
              <span class="wiki-tagline truncate">The Free Encyclopedia</span>
            </span>
          </a>
        </header>
        <form
          class="wiki-search"
          action="https://en.wikipedia.org/w/index.php"
          method="get"
        >
          <label class="sr-only" for="wikipedia-search">
            Search Wikipedia
          </label>
          <div class="wiki-search-control">
            <input
              id="wikipedia-search"
              class="wiki-search-input"
              name="search"
              type="search"
              placeholder="Search Wikipedia"
              autocomplete="off"
            />
            <button
              class="wiki-search-button"
              type="submit"
              aria-label="Search Wikipedia"
            >
              Search
            </button>
          </div>
        </form>
        <nav class="wiki-nav" aria-label="Wikipedia navigation">
          <a href="https://en.wikipedia.org/wiki/Main_Page">Main page</a>
          <a href="https://en.wikipedia.org/wiki/Wikipedia:Contents">Contents</a
          >
          <a href="https://en.wikipedia.org/wiki/Portal:Current_events"
            >Current events</a
          >
          <a href="https://en.wikipedia.org/wiki/Special:Random">Random</a>
        </nav>

        <div class="wiki-feature">
          <div class="wiki-feature-heading">
            <span>From today's featured article</span>
            <a
              href="https://en.wikipedia.org/wiki/Wikipedia:Today%27s_featured_article"
              aria-label="About today's featured article">?</a
            >
          </div>
          {#if wikipediaArticleLoading}
            <span class="sr-only" role="status">
              Loading Wikipedia's featured article
            </span>
            <div class="wiki-feature-loading" aria-hidden="true">
              <div class="wiki-skeleton-image"></div>
              <div class="wiki-skeleton-lines">
                <span></span>
                <span></span>
                <span></span>
              </div>
            </div>
          {:else if wikipediaArticleError || !wikipediaArticle}
            <div class="wiki-feature-error" role="status">
              <p>Today's featured article could not be reached.</p>
              <button type="button" onclick={loadWikipediaArticle}>
                Try again
              </button>
            </div>
          {:else}
            <article class="wiki-article">
              <div class="wiki-article-image">
                {#if wikipediaArticle.thumbnail}
                  <img src={wikipediaArticle.thumbnail.source} alt="" />
                {:else}
                  <div class="wiki-image-fallback" aria-hidden="true">W</div>
                {/if}
              </div>
              <div class="wiki-article-body">
                <h3 class="wiki-article-title">
                  <a href={wikipediaArticle.content_urls.desktop.page}>
                    {wikipediaArticleTitle(wikipediaArticle)}
                  </a>
                </h3>
                {#if wikipediaArticle.description}
                  <p class="wiki-article-description">
                    {wikipediaArticle.description}
                  </p>
                {/if}
                <p class="wiki-article-extract">
                  {wikipediaArticle.extract}
                </p>
                <a
                  class="wiki-read-more"
                  href={wikipediaArticle.content_urls.desktop.page}
                >
                  Full article...
                </a>
              </div>
            </article>
          {/if}
        </div>
      </section>

      <section class="card links" aria-labelledby="links-title">
        <header class="links-header">
          <h2 id="links-title">Links</h2>
        </header>
        <div class="links-body">
          {#each linkGroups as group (group.id)}
            <nav class="link-group" aria-labelledby={`links-${group.id}`}>
              <h3 class="press-kicker" id={`links-${group.id}`}>
                {group.title}
              </h3>
              {#each group.sites as site (site.href)}
                {@const live =
                  site.kickChannel && livestreams[site.kickChannel]}
                <a class="link" href={site.href}>
                  <!-- Private sites may not serve a favicon publicly. -->
                  {#if faviconMissing(site.hostname)}
                    <span
                      class="link-icon press-tile press-letter"
                      aria-hidden="true">{site.title[0]}</span
                    >
                  {:else}
                    <img
                      class="link-icon press-tile"
                      src={site.favicon}
                      alt=""
                      onerror={() => markFaviconMissing(site.hostname)}
                    />
                  {/if}
                  <span class="link-text">
                    <span class="link-heading">
                      <strong class="link-name truncate">{site.title}</strong>
                      {#if live}
                        <span class="link-live">
                          <span class="link-live-marker" aria-hidden="true"
                          ></span>
                          Live · {viewerCount.format(live.viewer_count)}
                          <span class="sr-only">watching</span>
                        </span>
                      {/if}
                      <small class="link-domain truncate">{site.hostname}</small
                      >
                      <span class="link-arrow" aria-hidden="true">↗</span>
                    </span>
                    <span class="link-description truncate">
                      {live ? live.session_title : site.description}
                    </span>
                  </span>
                </a>
              {/each}
            </nav>
          {/each}
        </div>
      </section>
    </div>

    <section class="card views" aria-label="Views" style:--seam={seam}>
      <div
        class="view-tabs"
        role="tablist"
        aria-label="Views"
        tabindex="-1"
        onkeydown={viewKeydown}
      >
        {#each views as { id, title } (id)}
          <button
            class="view-tab"
            id={`view-tab-${id}`}
            type="button"
            role="tab"
            aria-selected={view === id}
            aria-controls={`view-${id}`}
            tabindex={view === id ? 0 : -1}
            onclick={() => showView(id)}
          >
            {title}
          </button>
        {/each}
      </div>

      <div
        class="view view-apod"
        id="view-apod"
        role="tabpanel"
        aria-labelledby="view-tab-apod"
        aria-busy={astronomyPictureLoading}
        hidden={view !== "apod"}
      >
        {#if astronomyPictureLoading}
          <span class="sr-only" role="status">
            Loading NASA astronomy picture of the day
          </span>
          <div class="apod-placeholder" aria-hidden="true"></div>
        {:else if astronomyPictureError || !astronomyPicture}
          <div class="apod-placeholder apod-error" role="status">
            <p>NASA's astronomy picture could not be reached.</p>
            <div class="apod-actions">
              <button
                class="press-button"
                type="button"
                onclick={loadAstronomyPicture}
              >
                Try again
              </button>
              <a
                class="press-button"
                href="https://science.nasa.gov/apod/"
              >
                Open NASA APOD
              </a>
            </div>
          </div>
        {:else}
          <a
            class="apod-image"
            href={astronomyPictureTarget(astronomyPicture)}
            aria-label={`${astronomyPicture.video ? "Play video" : "Open full image"}: ${astronomyPicture.title}`}
            style:background-image={`url("${astronomyPictureUrl(astronomyPicture)}")`}
          >
            {#if astronomyPicture.video}
              <span class="apod-play" aria-hidden="true">▶</span>
            {/if}
          </a>
          <div class="apod-caption">
            <div class="seam" aria-hidden="true"></div>
            <p class="press-kicker">
              NASA astronomy picture of the day · {astronomyPictureDate(
                astronomyPicture.date,
              )}
            </p>
            <h3 class="apod-title">{astronomyPicture.title}</h3>
            <p class="apod-explanation">{astronomyPicture.explanation}</p>
            <p class="apod-credit">
              {astronomyPicture.copyright
                ? `Image: ${astronomyPicture.copyright}`
                : "Image: NASA"}
              {astronomyPicture.video
                ? " · Video thumbnail"
                : ""}
            </p>
          </div>
        {/if}
      </div>

      <div
        class="view"
        id="view-history"
        role="tabpanel"
        aria-labelledby="view-tab-history"
        hidden={view !== "history"}
      >
        {#if historyShown}
          {#if historyGraph?.sites.length}
            <!-- Loaded on first show: three.js is most of the page's code. -->
            {#await import("./HistoryGraph.svelte") then { default: Graph }}
              <Graph graph={historyGraph} visible={view === "history"} />
            {/await}
          {:else}
            <p class="press-empty">
              {historyGraph
                ? `No browsing in the last ${historyGraph.days} days.`
                : "History comes from Glide's config. Open this tab in Glide."}
            </p>
          {/if}
        {/if}
      </div>
    </section>
  </div>
</main>

<style>
  /* Dither Press (DESIGN.md): ink keylines on paper, one spot plate printed
     off-register behind whatever has focus or hover, square trims, halftone
     only at seams. Spacing and the page's own type come from the --press-*
     tokens, generated from the shell's fontSize like Theme.qml.
     Breakpoints: 640px and 1024px. At 1024px and up the page locks to one
     viewport: three columns over the views. */

  .page {
    min-block-size: 100dvh;
    padding: 1.25rem 1rem;
    background: var(--press-paper);
    color: var(--press-ink);

    @media (width >= 640px) {
      padding: 2rem 1.5rem;
    }

    @media (width >= 1024px) {
      block-size: 100dvh;
      min-block-size: 0;
      overflow: hidden;
      padding-block: 1.25rem;
    }
  }

  .shell {
    display: grid;
    gap: 1rem;
    max-inline-size: 1180px;
    margin-inline: auto;

    @media (width >= 1024px) {
      block-size: 100%;
      min-block-size: 0;
      grid-template-rows: clamp(380px, 50vh, 430px) minmax(0, 1fr);
    }
  }

  .columns {
    display: grid;
    gap: 1rem;

    @media (width >= 1024px) {
      min-block-size: 0;
      grid-template-columns: repeat(3, minmax(0, 1fr));
    }
  }

  /* Every card is a trimmed sheet with a 2px ink rule. The panel plate
     prints behind the one you are working in. */
  .card {
    min-inline-size: 0;
    overflow: hidden;
    border: var(--press-rule-width) solid var(--press-ink);

    &:focus-within {
      box-shadow: var(--press-panel-offset) var(--press-panel-offset) 0
        var(--press-plate);
    }
  }

  .sr-only {
    position: absolute;
    inline-size: 1px;
    block-size: 1px;
    margin: -1px;
    padding: 0;
    overflow: hidden;
    clip-path: inset(50%);
    white-space: nowrap;
  }

  .truncate {
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
  }

  .wiki-article-description,
  .wiki-article-extract,
  .apod-explanation {
    display: -webkit-box;
    -webkit-box-orient: vertical;
    -webkit-line-clamp: var(--lines);
    line-clamp: var(--lines);
    overflow: hidden;
  }

  /* Stamped things: hover reverses the face (ink fill, paper type) onto the
     spot plate, keyboard focus keeps paper with an ink keyline over the
     plate, and a press closes the offset. --fg/--bg are the face's own ink
     and paper, so reversed children (tiles, the live tag) follow along. */
  .press-button,
  .link {
    --fg: var(--press-ink);
    --bg: var(--press-paper);

    background: var(--bg);
    color: var(--fg);
    text-decoration: none;
    cursor: pointer;

    &:hover {
      --fg: var(--press-paper);
      --bg: var(--press-ink);

      box-shadow: var(--press-offset) var(--press-offset) 0 var(--press-plate);
    }

    &:focus-visible {
      outline: var(--press-rule-width) solid var(--press-ink);
      box-shadow: var(--press-offset) var(--press-offset) 0 var(--press-plate);
    }

    &:active {
      translate: var(--press-offset) var(--press-offset);
      box-shadow: none;
    }
  }

  /* A button rests on an ink plate; a link row rests flat on the paper. */
  .press-button {
    padding: var(--press-half-gap) var(--press-gap);
    border: var(--press-rule-width) solid var(--press-ink);
    box-shadow: var(--press-offset) var(--press-offset) 0 var(--press-ink);
    font-size: var(--press-font-size);
    font-weight: 700;
    line-height: 1;
    text-transform: uppercase;
  }

  /* Hacker News and Wikipedia keep their own colours and type inside the
     press frame, the way tray icons keep theirs (App Identity Exception). */

  .hn,
  .wiki {
    --brand-sans: Inter, ui-sans-serif, system-ui, sans-serif;

    font-family: var(--brand-sans);

    & :is(a, button):focus-visible {
      outline: 2px solid var(--brand-focus);
    }
  }

  .hn {
    --hn-orange: #ff6600;
    --hn-paper: #f6f6ef;
    --hn-muted: #5f5f5f;
    --hn-skeleton: #e4e4dc;
    --brand-focus: #005fcc;

    display: flex;
    flex-direction: column;
    background: var(--hn-paper);
    color: black;
    font-size: 13px;

    @media (width >= 640px) {
      min-block-size: 390px;
    }

    @media (width >= 1024px) {
      min-block-size: 0;
    }
  }

  .hn-header {
    display: flex;
    align-items: center;
    min-block-size: 1.75rem;
    padding: 2px;
    background: var(--hn-orange);
    white-space: nowrap;

    & h2 {
      margin: 0;
      font-size: 13px;
      line-height: 1;
    }

    & a {
      color: black;
      text-decoration: none;
    }

    & .hn-logo {
      display: grid;
      place-items: center;
      inline-size: 1.25rem;
      block-size: 1.25rem;
      margin-inline-end: 5px;
      border: 1px solid white;
      color: white;
    }
  }

  .hn-name {
    margin-inline-end: 7px;
    font-weight: 700;
  }

  .hn-content {
    flex: 1;
    min-block-size: 0;
    padding: 0.5rem 7px;

    @media (width >= 640px) {
      padding: 0.875rem 0.5rem;
    }

    @media (width >= 1024px) {
      padding-block: 0.5rem;
    }
  }

  .story-list {
    display: grid;
    align-content: space-between;
    gap: 11px;
    block-size: 100%;
    margin: 0;
    padding: 0;
    list-style: none;

    @media (width >= 640px) {
      gap: 9px;
    }

    @media (width >= 1024px) {
      gap: 2px;
    }
  }

  .story {
    display: grid;
    grid-template-columns: 24px minmax(0, 1fr);
  }

  .story-loading {
    min-block-size: 30px;
  }

  .rank {
    padding-block-start: 1px;
    color: var(--hn-muted);
    text-align: end;
  }

  .story-main {
    min-inline-size: 0;
  }

  .story-heading {
    display: flex;
    align-items: start;
    min-inline-size: 0;
    padding-inline-start: 5px;
    line-height: 1rem;

    @media (width >= 640px) {
      align-items: baseline;
    }
  }

  .story-title {
    min-inline-size: 0;
    color: black;
    text-decoration: none;

    &:visited {
      color: var(--hn-muted);
    }

    @media (width >= 640px) {
      overflow: hidden;
      text-overflow: ellipsis;
      white-space: nowrap;
    }
  }

  .story-host {
    display: none;
    flex: auto;
    margin-inline-start: 5px;
    color: var(--hn-muted);
    font-size: 11px;

    @media (width >= 640px) {
      display: block;
    }
  }

  .story-meta {
    display: flex;
    flex-wrap: wrap;
    align-items: center;
    column-gap: 6px;
    margin: 4px 0 0 5px;
    color: var(--hn-muted);
    font-size: 11px;
    line-height: 1rem;

    @media (width >= 1024px) {
      margin-block-start: 0;
      line-height: 14px;
    }

    & a {
      color: inherit;
      text-decoration: none;
      text-underline-offset: 2px;

      &:hover {
        text-decoration: underline;
      }
    }
  }

  .loading-title,
  .loading-meta {
    display: block;
    background: var(--hn-skeleton);
  }

  .loading-title {
    inline-size: min(78%, 480px);
    block-size: 10px;
    margin-block-start: 3px;
  }

  .loading-meta {
    inline-size: min(40%, 230px);
    block-size: 7px;
    margin-block-start: 0.5rem;
  }

  .hn-state {
    display: grid;
    place-content: center;
    justify-items: center;
    min-block-size: 280px;
    color: var(--hn-muted);
  }

  .hn-retry {
    border: 0;
    border-block-end: 1px solid var(--hn-muted);
    background: none;
    color: black;
    font-size: 11px;
    cursor: pointer;
  }

  .wiki {
    --wiki-link: #36c;
    --wiki-text: #202122;
    --wiki-subtle: #54595d;
    --wiki-rule: #c8ccd1;
    --wiki-field: #72777d;
    --wiki-chrome: #f8f9fa;
    --wiki-skeleton: #eaecf0;
    --wiki-feature-rule: #a3bfb1;
    --wiki-serif: Georgia, serif;
    --brand-focus: var(--wiki-link);

    display: flex;
    flex-direction: column;
    background: white;
    color: var(--wiki-text);
  }

  .wiki-header {
    padding: 0.625rem 1rem;
    border-block-end: 1px solid var(--wiki-rule);
    background: var(--wiki-chrome);
  }

  .wiki-brand {
    display: flex;
    align-items: center;
    gap: 0.625rem;
    min-inline-size: 0;
    color: inherit;
    text-decoration: none;
  }

  .wiki-brand-text {
    min-inline-size: 0;
  }

  .wiki-mark {
    display: grid;
    flex: none;
    place-items: center;
    inline-size: 2.5rem;
    block-size: 2.5rem;
    color: black;
    font: 34px/1 var(--wiki-serif);
  }

  .wiki-wordmark {
    margin: 0;
    color: black;
    font: 400 20px/1.25rem var(--wiki-serif);
    letter-spacing: 0.02em;
  }

  .wiki-tagline {
    display: block;
    margin-block-start: 2px;
    color: var(--wiki-subtle);
    font-size: 9px;
    letter-spacing: 0.08em;
  }

  .wiki-search {
    padding: 0.75rem;
    border-block-end: 1px solid var(--wiki-rule);
  }

  .wiki-search-control {
    display: flex;
    min-inline-size: 0;
    border: 1px solid var(--wiki-field);

    &:focus-within {
      border-color: var(--wiki-link);
      box-shadow: 0 0 0 1px var(--wiki-link);
    }
  }

  .wiki-search-input {
    flex: 1;
    min-inline-size: 0;
    padding: 7px 10px;
    border: 0;
    outline: none;
    background: white;
    color: var(--wiki-text);
    font-size: 12px;

    &::placeholder {
      color: var(--wiki-field);
    }
  }

  .wiki-search-button,
  .wiki-feature-error button {
    background: var(--wiki-chrome);
    color: var(--wiki-text);
    font-weight: 600;
    cursor: pointer;

    &:hover {
      background: white;
    }
  }

  .wiki-search-button {
    padding-inline: 0.75rem;
    border: 0;
    border-inline-start: 1px solid var(--wiki-field);
    font-size: 11px;

    &:focus-visible {
      outline-offset: -2px;
    }
  }

  .wiki-nav {
    display: flex;
    flex-wrap: wrap;
    gap: 0.25rem 0.75rem;
    padding: 0.5rem 0.75rem;
    border-block-end: 1px solid var(--wiki-rule);
    background: var(--wiki-chrome);
    font-size: 10px;
  }

  .wiki-nav a,
  .wiki-article-title a,
  .wiki-read-more {
    color: var(--wiki-link);
    text-decoration: none;

    &:hover {
      text-decoration: underline;
    }
  }

  .wiki-feature {
    display: flex;
    flex: 1;
    flex-direction: column;
    min-block-size: 0;
    margin: 0.75rem;
    overflow: hidden;
    border: 1px solid var(--wiki-feature-rule);
    background: #f5fffa;
  }

  .wiki-feature-heading {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 4px 10px;
    border-block-end: 1px solid var(--wiki-feature-rule);
    background: #cef2e0;
    color: black;
    font: 700 14px/1.5 var(--wiki-serif);

    & a {
      display: grid;
      place-items: center;
      inline-size: 1rem;
      block-size: 1rem;
      border: 1px solid var(--wiki-field);
      border-radius: 50%;
      color: var(--wiki-link);
      font-family: var(--brand-sans);
      font-size: 10px;
      text-decoration: none;
    }
  }

  .wiki-feature-loading,
  .wiki-article {
    display: grid;
    align-content: start;
    gap: 0.75rem;
    padding: 0.75rem;

    @media (width >= 1024px) {
      grid-template-columns: 112px minmax(0, 1fr);
    }
  }

  .wiki-feature-loading {
    min-block-size: 11rem;
  }

  .wiki-skeleton-image {
    block-size: 7rem;
    background: var(--wiki-skeleton);
  }

  .wiki-skeleton-lines {
    display: grid;
    align-content: start;
    gap: 0.5rem;

    & span {
      block-size: 10px;
      background: var(--wiki-skeleton);
    }

    & span:first-child {
      inline-size: 75%;
      block-size: 1rem;
      background: var(--wiki-rule);
    }

    & span:last-child {
      inline-size: calc(5 / 6 * 100%);
    }
  }

  .wiki-feature-error {
    display: grid;
    place-content: center;
    justify-items: center;
    gap: 0.75rem;
    min-block-size: 11rem;
    padding: 1rem;
    font-size: 11px;
    text-align: center;

    & p {
      margin: 0;
    }

    & button {
      padding: 6px 0.75rem;
      border: 1px solid var(--wiki-field);
    }
  }

  .wiki-article {
    flex: 1;
    min-block-size: 0;
    overflow: hidden;
    font-size: 11px;
    line-height: 1rem;
  }

  .wiki-article-image {
    block-size: 7rem;
    padding: 0.25rem;
    overflow: hidden;
    border: 1px solid var(--wiki-rule);
    background: white;

    @media (width >= 1024px) {
      block-size: 6rem;
    }

    & img {
      inline-size: 100%;
      block-size: 100%;
      object-fit: cover;
    }
  }

  .wiki-image-fallback {
    display: grid;
    place-items: center;
    block-size: 100%;
    background: var(--wiki-skeleton);
    color: var(--wiki-subtle);
    font: 3rem/1 var(--wiki-serif);
  }

  .wiki-article-body {
    min-inline-size: 0;
  }

  .wiki-article-title {
    margin: 0;
    font: 700 15px/18px var(--wiki-serif);
  }

  .wiki-article-description {
    --lines: 2;

    margin: 4px 0 0;
    color: var(--wiki-subtle);
    font-size: 10px;
    font-style: italic;
  }

  .wiki-article-extract {
    --lines: 7;

    margin: 0.5rem 0 0;

    @media (width >= 1024px) {
      --lines: 3;
    }
  }

  .wiki-read-more {
    display: inline-block;
    margin-block-start: 0.5rem;
    font-size: 10px;
  }

  /* Links: a press panel of slugs. Type sits straight on paper at rest; the
     row stamps like a press button (see .press-button, .link above). */

  .links {
    display: flex;
    flex-direction: column;
  }

  .links-header {
    padding: var(--press-gap) var(--press-inset);
    border-block-end: var(--press-rule-width) solid var(--press-ink);

    & h2 {
      margin: 0;
      font-size: var(--press-heading-size);
      font-weight: 700;
      line-height: 1;
      text-transform: uppercase;
    }
  }

  .links-body {
    display: grid;
    align-content: start;
    gap: var(--press-gap);
    min-block-size: 0;
    padding: var(--press-gap);
    overflow-y: auto;
  }

  .link-group {
    display: grid;
    gap: 2px;

    & h3 {
      margin: 0 0 4px;
      padding-inline: var(--press-half-gap);
    }
  }

  .link {
    --muted: var(--press-muted);

    display: grid;
    grid-template-columns: var(--press-tile-size) minmax(0, 1fr);
    align-items: start;
    gap: var(--press-gap);
    padding: var(--press-half-gap);

    &:hover {
      --muted: currentColor;
    }

    &:focus-visible {
      outline-offset: calc(-1 * var(--press-rule-width));
    }
  }

  .link-icon {
    --size: var(--press-tile-size);
  }

  .link-text {
    display: grid;
    gap: 2px;
    min-inline-size: 0;
  }

  .link-heading {
    display: flex;
    align-items: center;
    gap: var(--press-half-gap);
    min-inline-size: 0;
  }

  .link-name {
    min-inline-size: 0;
    font-size: var(--press-font-size);
    font-weight: 700;
    line-height: 1.25;
  }

  /* A caption tag reversed out of the row's ink. */
  .link-live {
    display: flex;
    flex: none;
    align-items: center;
    gap: 4px;
    padding: 2px 4px;
    background: var(--fg);
    color: var(--bg);
    font-size: var(--press-caption-size);
    font-weight: 700;
    line-height: 1;
    text-transform: uppercase;
  }

  /* Danger hue always travels with its square. */
  .link-live-marker {
    flex: none;
    inline-size: 6px;
    block-size: 6px;
    background: var(--press-danger);
  }

  .link-domain {
    min-inline-size: 0;
    margin-inline-start: auto;
    color: var(--muted);
    font-size: var(--press-caption-size);
    line-height: 1.25;
  }

  .link-arrow {
    flex: none;
    font-size: var(--press-font-size);
    line-height: 1;
  }

  .link-description {
    font-size: var(--press-font-size);
    line-height: 1.25;
  }

  /* Big views: one panel, a strip of stamped tabs over whichever view is
     showing. The selected tab is the focused workspace chip: paper with an
     ink rule over the spot plate. */

  .views {
    display: grid;
    grid-template-rows: auto minmax(0, 1fr);
    block-size: clamp(360px, 56vh, 620px);

    @media (width >= 1024px) {
      block-size: 100%;
      min-block-size: 0;
    }
  }

  .view-tabs {
    display: flex;
    gap: var(--press-gap);
    padding: var(--press-half-gap) var(--press-gap)
      calc(var(--press-half-gap) + var(--press-offset));
    border-block-end: var(--press-rule-width) solid var(--press-ink);
  }

  .view-tab {
    padding: 4px 8px;
    border: var(--press-rule-width) solid transparent;
    background: none;
    color: var(--press-ink);
    font-size: var(--press-font-size);
    font-weight: 700;
    line-height: 1;
    text-transform: uppercase;
    cursor: pointer;

    &:hover {
      border-color: var(--press-ink);
    }

    &[aria-selected="true"] {
      border-color: var(--press-ink);
      background: var(--press-paper);
      box-shadow: var(--press-plate-offset) var(--press-plate-offset) 0
        var(--press-plate);
    }

    &:focus-visible {
      outline: var(--press-rule-width) solid var(--press-ink);
      outline-offset: 2px;
    }

    &:active {
      translate: var(--press-plate-offset) var(--press-plate-offset);
      box-shadow: none;
    }
  }

  .view {
    min-block-size: 0;

    &[hidden] {
      display: none;
    }
  }

  /* NASA astronomy picture of the day: the picture over a paper caption
     whose top edge breaks up into halftone instead of fading. */

  .view-apod {
    display: grid;
    grid-template-rows: minmax(0, 1fr) auto;
    background: var(--press-surface);
  }

  .apod-placeholder {
    grid-row: 1 / -1;
  }

  .apod-error {
    display: grid;
    place-content: center;
    justify-items: center;
    gap: var(--press-inset);
    padding-inline: var(--press-inset);
    text-align: center;

    & p {
      margin: 0;
      font-size: var(--press-font-size);
    }
  }

  .apod-actions {
    display: flex;
    flex-wrap: wrap;
    justify-content: center;
    gap: var(--press-gap);
  }

  .apod-image {
    position: relative;
    display: grid;
    place-items: center;
    background: center / cover no-repeat;

    &:focus-visible {
      outline: calc(2 * var(--press-rule-width)) solid var(--press-ink);
      outline-offset: calc(-2 * var(--press-rule-width));
    }
  }

  .apod-play {
    display: grid;
    place-items: center;
    inline-size: 48px;
    block-size: 48px;
    background: var(--press-ink);
    box-shadow: var(--press-offset) var(--press-offset) 0 var(--press-paper);
    color: var(--press-paper);
    font-size: var(--press-heading-size);

    .apod-image:hover & {
      box-shadow: var(--press-offset) var(--press-offset) 0 var(--press-plate);
    }
  }

  .apod-caption {
    position: relative;
    display: grid;
    gap: var(--press-half-gap);
    padding: var(--press-gap) var(--press-inset) var(--press-inset);
    background: var(--press-paper);

    & > * {
      margin: 0;
    }
  }

  .seam {
    position: absolute;
    inset-inline: 0;
    bottom: 100%;
    block-size: var(--press-seam-height);
    background: var(--press-paper);
    mask: var(--seam);
    pointer-events: none;
  }

  .apod-title {
    font-size: var(--press-heading-size);
    font-weight: 700;
    line-height: 1.2;
    text-transform: uppercase;
    text-wrap: balance;
  }

  .apod-explanation {
    --lines: 2;

    max-inline-size: 96ch;
    font-size: var(--press-font-size);
    line-height: 1.5;
  }

  .apod-credit {
    color: var(--press-muted);
    font-size: var(--press-caption-size);
  }
</style>
