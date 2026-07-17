<script lang="ts">
  import { onMount } from "svelte";

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
    hdurl?: string;
    media_type: "image" | "video";
    thumbnail_url?: string;
    title: string;
    url: string;
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

  const hackerNewsApi = "https://hacker-news.firebaseio.com/v0";
  const astronomyPictureApi =
    "https://api.nasa.gov/planetary/apod?api_key=DEMO_KEY&thumbs=true";
  const mediaSites = [
    {
      href: "https://youtube.com/",
      title: "YouTube",
      description: "Videos, music, subscriptions, and live streams.",
      kind: "Video",
    },
    {
      href: "https://reddit.com/",
      title: "Reddit",
      description: "Communities, conversations, news, and discovery.",
      kind: "Communities",
    },
    {
      href: "https://destiny.gg/",
      title: "Destiny",
      description: "Livestreams, debates, events, and the DGG community.",
      kind: "Live & community",
    },
    {
      href: "https://apnews.com/",
      title: "AP News",
      description:
        "Independent reporting and breaking news from around the world.",
      kind: "News",
    },
  ].map((site) => {
    const url = new URL(site.href);
    const hostname = url.hostname.replace(/^www\./, "");

    return {
      ...site,
      hostname,
      favicon: new URL("/favicon.ico", url).href,
    };
  });

  let stories: HackerNewsStory[] = [];
  let loading = true;
  let error = false;
  let wikipediaArticle: WikipediaArticle | undefined;
  let wikipediaArticleLoading = true;
  let wikipediaArticleError = false;
  let astronomyPicture: AstronomyPicture | undefined;
  let astronomyPictureLoading = true;
  let astronomyPictureError = false;

  function storyUrl(story: HackerNewsStory) {
    return story.url ?? `https://news.ycombinator.com/item?id=${story.id}`;
  }

  function storyHost(story: HackerNewsStory) {
    if (!story.url) return "news.ycombinator.com";

    try {
      return new URL(story.url).hostname.replace(/^www\./, "");
    } catch {
      return "";
    }
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
        ids.slice(0, 12).map(async (id) => {
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
      const cached = localStorage.getItem(cacheKey);
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
      // Fetch a fresh copy when storage is unavailable or stale.
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
      try {
        localStorage.setItem(cacheKey, JSON.stringify({ date, article }));
      } catch {
        // The article can still be displayed without browser storage.
      }
    } catch {
      wikipediaArticleError = true;
    } finally {
      wikipediaArticleLoading = false;
    }
  }

  function astronomyPictureUrl(picture: AstronomyPicture) {
    return picture.media_type === "image" ? picture.url : picture.thumbnail_url;
  }

  function astronomyPictureTarget(picture: AstronomyPicture) {
    return picture.media_type === "image"
      ? (picture.hdurl ?? picture.url)
      : picture.url;
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
      const cached = localStorage.getItem(cacheKey);
      if (cached) {
        const { date: cachedDate, picture } = JSON.parse(cached) as {
          date: string;
          picture: AstronomyPicture;
        };
        if (cachedDate === date && astronomyPictureUrl(picture)) {
          astronomyPicture = picture;
          astronomyPictureLoading = false;
          return;
        }
      }
    } catch {
      // Fetch a fresh copy when storage is unavailable or stale.
    }

    try {
      const response = await fetch(astronomyPictureApi, { signal });
      if (!response.ok) throw new Error("Could not load NASA APOD");

      const picture = (await response.json()) as AstronomyPicture;
      if (!astronomyPictureUrl(picture)) {
        throw new Error("NASA APOD did not provide an image");
      }

      astronomyPicture = picture;
      try {
        localStorage.setItem(cacheKey, JSON.stringify({ date, picture }));
      } catch {
        // The image can still be displayed without browser storage.
      }
    } catch {
      astronomyPictureError = true;
    } finally {
      astronomyPictureLoading = false;
    }
  }

  onMount(() => {
    loadStories();
    loadWikipediaArticle();
    loadAstronomyPicture();
  });
</script>

<main class="min-h-screen bg-base00 px-4 py-5 text-base07 sm:px-6 sm:py-8">
  <div class="mx-auto max-w-[1180px]">
    <h1 class="sr-only">New tab</h1>
    <div class="grid gap-4 lg:grid-cols-3">
      <section
        class="hn-frame min-w-0"
        aria-labelledby="hacker-news-title"
        aria-busy={loading}
      >
        <div class="hn-page">
          <header class="hn-header">
            <a
              class="hn-logo"
              href="https://news.ycombinator.com/"
              aria-label="Hacker News home">Y</a
            >
            <h2 class="m-0 text-[13px] leading-none">
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
              <ol
                class="story-list"
                aria-label="Loading top Hacker News stories"
                aria-hidden="true"
              >
                {#each Array(12) as _, index}
                  <li class="story story-loading">
                    <span class="rank">{index + 1}.</span>
                    <div class="story-main">
                      <span class="loading-block"></span>
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
                          <span class="story-host">({storyHost(story)})</span>
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
        </div>
      </section>

      <div class="contents">
        <section
          class="wiki-frame"
          aria-labelledby="wiki-title"
          aria-busy={wikipediaArticleLoading}
        >
          <header class="wiki-header">
            <a
              class="wiki-brand"
              href="https://en.wikipedia.org/wiki/Main_Page"
            >
              <span class="wiki-mark" aria-hidden="true">W</span>
              <span class="min-w-0">
                <h2 id="wiki-title" class="wiki-wordmark">Wikipedia</h2>
                <span class="wiki-tagline">The Free Encyclopedia</span>
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
            <a href="https://en.wikipedia.org/wiki/Wikipedia:Contents"
              >Contents</a
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
                <div
                  class="h-28 animate-pulse bg-[#eaecf0] motion-reduce:animate-none"
                ></div>
                <div class="grid content-start gap-2">
                  <span
                    class="h-4 w-3/4 animate-pulse bg-[#c8ccd1] motion-reduce:animate-none"
                  ></span>
                  <span
                    class="h-2.5 animate-pulse bg-[#eaecf0] motion-reduce:animate-none"
                  ></span>
                  <span
                    class="h-2.5 w-5/6 animate-pulse bg-[#eaecf0] motion-reduce:animate-none"
                  ></span>
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
                    <img
                      class="h-full w-full object-cover"
                      src={wikipediaArticle.thumbnail.source}
                      alt=""
                    />
                  {:else}
                    <div class="wiki-image-fallback" aria-hidden="true">W</div>
                  {/if}
                </div>
                <div class="min-w-0">
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

        <section
          class="widget overflow-hidden border border-base02 bg-base01"
          aria-labelledby="media-title"
        >
          <div class="border-b border-base02 px-5 py-4">
            <h2 id="media-title" class="m-0 text-base font-medium text-base07">
              Media
            </h2>
          </div>
          <nav class="media-links" aria-label="Media shortcuts">
            {#each mediaSites as site (site.href)}
              <a class="media-link" href={site.href}>
                <img class="media-favicon" src={site.favicon} alt="" />
                <span class="min-w-0">
                  <span class="media-heading">
                    <strong class="media-name">{site.title}</strong>
                    <span class="arrow" aria-hidden="true">↗</span>
                  </span>
                  <span class="media-description">{site.description}</span>
                  <span class="media-details">
                    <small class="media-domain">{site.hostname}</small>
                    <small class="media-kind">{site.kind}</small>
                  </span>
                </span>
              </a>
            {/each}
          </nav>
        </section>
      </div>
    </div>

    <section
      class="widget relative mt-4 h-[clamp(360px,56vh,620px)] overflow-hidden border border-base03 bg-base01"
      aria-labelledby="astronomy-picture-title"
      aria-busy={astronomyPictureLoading}
    >
      <h2 id="astronomy-picture-title" class="sr-only">
        NASA astronomy picture of the day
      </h2>
      {#if astronomyPictureLoading}
        <span class="sr-only" role="status">
          Loading NASA astronomy picture of the day
        </span>
        <div
          class="h-full w-full animate-pulse bg-gradient-to-br from-base01 via-base02 to-base00 motion-reduce:animate-none"
          aria-hidden="true"
        ></div>
      {:else if astronomyPictureError || !astronomyPicture}
        <div
          class="grid h-full place-content-center justify-items-center gap-3 bg-gradient-to-br from-base01 via-base02 to-base00 px-6 text-center"
          role="status"
        >
          <p class="m-0 text-sm text-base07">
            NASA's astronomy picture could not be reached.
          </p>
          <div class="flex flex-wrap justify-center gap-3">
            <button
              class="cursor-pointer border border-base0D bg-base00 px-3 py-1.5 text-xs text-base0D hover:bg-base03 hover:text-base07 focus-visible:outline-2 focus-visible:outline-base0D focus-visible:outline-offset-2"
              type="button"
              onclick={loadAstronomyPicture}
            >
              Try again
            </button>
            <a
              class="border border-base0E bg-base00 px-3 py-1.5 text-xs text-base0E no-underline hover:bg-base03 hover:text-base07 focus-visible:outline-2 focus-visible:outline-base0E focus-visible:outline-offset-2"
              href="https://apod.nasa.gov/apod/astropix.html"
            >
              Open NASA APOD
            </a>
          </div>
        </div>
      {:else}
        <a
          class="block h-full bg-cover bg-center bg-no-repeat focus-visible:outline-2 focus-visible:outline-base0D focus-visible:outline-offset--2"
          href={astronomyPictureTarget(astronomyPicture)}
          aria-label={`${astronomyPicture.media_type === "video" ? "Play video" : "Open full image"}: ${astronomyPicture.title}`}
          style:background-image={`url("${astronomyPictureUrl(astronomyPicture)}")`}
        >
          {#if astronomyPicture.media_type === "video"}
            <span
              class="pointer-events-none absolute left-1/2 top-1/2 grid h-16 w-16 -translate-x-1/2 -translate-y-1/2 place-items-center rounded-full border border-white/70 bg-black/70 text-2xl text-white shadow-xl"
              aria-hidden="true">▶</span
            >
          {/if}
        </a>
        <div
          class="pointer-events-none absolute inset-x-0 bottom-0 bg-gradient-to-t from-black/95 via-black/65 to-transparent px-5 pb-5 pt-28 text-white sm:px-7 sm:pb-7"
        >
          <p
            class="m-0 text-[10px] font-semibold tracking-[0.18em] text-base0D uppercase"
          >
            NASA astronomy picture of the day · {astronomyPictureDate(
              astronomyPicture.date,
            )}
          </p>
          <h3
            class="m-0 mt-2 text-2xl font-medium tracking-[-0.025em] text-white sm:text-3xl"
          >
            {astronomyPicture.title}
          </h3>
          <p
            class="m-0 mt-2 max-w-3xl line-clamp-3 text-xs leading-5 text-white/85 sm:text-sm"
          >
            {astronomyPicture.explanation}
          </p>
          <p class="m-0 mt-3 text-[11px] text-white/75">
            {astronomyPicture.copyright
              ? `Image: ${astronomyPicture.copyright}`
              : "Image: NASA"}
            {astronomyPicture.media_type === "video"
              ? " · Video thumbnail"
              : ""}
          </p>
        </div>
      {/if}
    </section>
  </div>
</main>
