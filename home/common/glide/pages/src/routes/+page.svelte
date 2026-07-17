<script lang="ts">
  import { onMount } from "svelte";

  type HackerNewsStory = {
    by: string;
    descendants?: number;
    id: number;
    score: number;
    time: number;
    title: string;
    type: string;
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

  const hackerNewsApi = "https://hacker-news.firebaseio.com/v0";
  const astronomyPictureApi =
    "https://api.nasa.gov/planetary/apod?api_key=DEMO_KEY&thumbs=true";
  const mediaUrls = [
    "https://destiny.gg/",
    "https://youtube.com/",
    "https://reddit.com/",
  ];
  const mediaMetadata: Record<
    string,
    { title: string; description: string; kind: string }
  > = {
    "destiny.gg": {
      title: "Destiny",
      description: "Livestreams, debates, events, and the DGG community.",
      kind: "Live & community",
    },
    "youtube.com": {
      title: "YouTube",
      description: "Videos, music, subscriptions, and live streams.",
      kind: "Video",
    },
    "reddit.com": {
      title: "Reddit",
      description: "Communities, conversations, news, and discovery.",
      kind: "Communities",
    },
  };
  const mediaSites = mediaUrls.map((href) => {
    const url = new URL(href);
    const hostname = url.hostname.replace(/^www\./, "");

    return {
      href,
      hostname,
      favicon: new URL("/favicon.ico", url).href,
      ...mediaMetadata[hostname],
    };
  });

  let stories: HackerNewsStory[] = [];
  let loading = true;
  let error = false;
  let storiesController: AbortController;
  let astronomyPicture: AstronomyPicture | undefined;
  let astronomyPictureLoading = true;
  let astronomyPictureError = false;
  let astronomyPictureController: AbortController;

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

  async function loadStories() {
    storiesController?.abort();
    storiesController = new AbortController();
    loading = true;
    error = false;

    try {
      const topResponse = await fetch(`${hackerNewsApi}/topstories.json`, {
        signal: storiesController.signal,
      });
      if (!topResponse.ok) throw new Error("Could not load Hacker News");

      const ids = (await topResponse.json()) as number[];
      const responses = await Promise.all(
        ids.slice(0, 8).map((id) =>
          fetch(`${hackerNewsApi}/item/${id}.json`, {
            signal: storiesController.signal,
          }),
        ),
      );
      if (responses.some((response) => !response.ok)) {
        throw new Error("Could not load Hacker News stories");
      }

      stories = (
        await Promise.all(
          responses.map(
            (response) => response.json() as Promise<HackerNewsStory>,
          ),
        )
      ).filter(Boolean);
    } catch (cause) {
      if (!(cause instanceof DOMException && cause.name === "AbortError")) {
        error = true;
      }
    } finally {
      loading = false;
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
    astronomyPictureController?.abort();
    astronomyPictureController = new AbortController();
    astronomyPictureLoading = true;
    astronomyPictureError = false;
    const cacheKey = `nasa-apod:${new Date().toLocaleDateString("en-CA")}`;

    try {
      const cached = localStorage.getItem(cacheKey);
      if (cached) {
        const picture = JSON.parse(cached) as AstronomyPicture;
        if (astronomyPictureUrl(picture)) {
          astronomyPicture = picture;
          astronomyPictureLoading = false;
          return;
        }
      }
    } catch {
      // Fetch a fresh copy when storage is unavailable or stale.
    }

    try {
      const response = await fetch(astronomyPictureApi, {
        signal: astronomyPictureController.signal,
      });
      if (!response.ok) throw new Error("Could not load NASA APOD");

      const picture = (await response.json()) as AstronomyPicture;
      if (!astronomyPictureUrl(picture)) {
        throw new Error("NASA APOD did not provide an image");
      }

      astronomyPicture = picture;
      try {
        localStorage.setItem(cacheKey, JSON.stringify(picture));
      } catch {
        // The image can still be displayed without browser storage.
      }
    } catch (cause) {
      if (!(cause instanceof DOMException && cause.name === "AbortError")) {
        astronomyPictureError = true;
      }
    } finally {
      astronomyPictureLoading = false;
    }
  }

  onMount(() => {
    loadStories();
    loadAstronomyPicture();
    return () => {
      storiesController?.abort();
      astronomyPictureController?.abort();
    };
  });
</script>

<svelte:head>
  <title>New tab</title>
  <meta
    name="description"
    content="Glide new tab with Hacker News, Wikipedia, media shortcuts, and NASA's astronomy picture of the day"
  />
</svelte:head>

<main class="min-h-screen bg-base00 px-4 py-5 text-base07 sm:px-6 sm:py-8">
  <div class="mx-auto max-w-[1180px]">
    <header class="mb-5 px-1 sm:mb-7">
      <h1 class="m-0 text-xl font-medium tracking-[-0.025em] text-base07">
        New tab
      </h1>
    </header>

    <div class="dashboard-grid grid gap-4 lg:grid-cols-3">
      <section
        class="hn-frame min-w-0 overflow-hidden"
        aria-labelledby="hacker-news-title"
      >
        <div class="hn-page">
          <header class="hn-header">
            <a
              class="hn-logo"
              href="https://news.ycombinator.com/"
              aria-label="Hacker News home">Y</a
            >
            <a
              class="hn-name"
              id="hacker-news-title"
              href="https://news.ycombinator.com/"
            >
              Hacker News
            </a>
          </header>

          <div class="hn-content" aria-live="polite">
            {#if loading}
              <ol
                class="story-list"
                aria-label="Loading top Hacker News stories"
              >
                {#each Array(8) as _, index}
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
                        <span class="votearrow" aria-hidden="true"></span>
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

          <footer class="hn-footer">
            <a href="https://news.ycombinator.com/news?p=2">More</a>
          </footer>
        </div>
      </section>

      <div class="contents">
        <section
          class="widget overflow-hidden border border-base02 bg-base01"
          aria-labelledby="wiki-title"
        >
          <div
            class="widget-header flex items-center justify-between border-b border-base02 px-5 py-4"
          >
            <h2
              id="wiki-title"
              class="m-0 text-base font-medium text-base07"
            >
              Wikipedia
            </h2>
            <span class="wiki-mark text-3xl text-base06" aria-hidden="true"
              >W</span
            >
          </div>
          <form
            class="p-5"
            action="https://en.wikipedia.org/w/index.php"
            method="get"
          >
            <label
              class="mb-2 block text-xs text-base05"
              for="wikipedia-search"
            >
              Search the free encyclopedia
            </label>
            <div
              class="flex overflow-hidden border border-base03 bg-base00 focus-within:border-base0D"
            >
              <input
                id="wikipedia-search"
                class="min-w-0 flex-1 border-0 bg-transparent px-3 py-2.5 text-sm text-base07 outline-none placeholder:text-base04"
                name="search"
                type="search"
                placeholder="Search Wikipedia"
                autocomplete="off"
              />
              <button
                class="grid w-11 cursor-pointer place-items-center border-0 border-l border-base03 bg-base02 text-base06 hover:bg-base03 hover:text-base07"
                type="submit"
                aria-label="Search Wikipedia"
              >
                <svg
                  viewBox="0 0 24 24"
                  width="16"
                  height="16"
                  aria-hidden="true"
                >
                  <circle
                    cx="10.5"
                    cy="10.5"
                    r="6.5"
                    fill="none"
                    stroke="currentColor"
                    stroke-width="1.7"
                  />
                  <path
                    d="m15.5 15.5 4 4"
                    fill="none"
                    stroke="currentColor"
                    stroke-linecap="round"
                    stroke-width="1.7"
                  />
                </svg>
              </button>
            </div>
          </form>
        </section>

        <section
          class="widget overflow-hidden border border-base02 bg-base01"
          aria-labelledby="media-title"
        >
          <div class="widget-header border-b border-base02 px-5 py-4">
            <h2
              id="media-title"
              class="m-0 text-base font-medium text-base07"
            >
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
      class="widget relative mt-4 h-[clamp(420px,62vh,700px)] overflow-hidden border border-base03 bg-base01"
      aria-labelledby="astronomy-picture-title"
      aria-live="polite"
    >
      {#if astronomyPictureLoading}
        <div
          class="h-full w-full animate-pulse bg-gradient-to-br from-base01 via-base02 to-base00"
          aria-label="Loading NASA astronomy picture of the day"
        ></div>
      {:else if astronomyPictureError || !astronomyPicture}
        <div
          class="grid h-full place-content-center justify-items-center gap-3"
        >
          <p class="m-0 text-sm text-base05">
            NASA's astronomy picture could not be reached.
          </p>
          <button
            class="cursor-pointer border border-base03 bg-base02 px-3 py-1.5 text-xs text-base06 hover:border-base0D hover:text-base07"
            type="button"
            onclick={loadAstronomyPicture}
          >
            Try again
          </button>
        </div>
      {:else}
        <a
          class="block h-full bg-black"
          href={astronomyPictureTarget(astronomyPicture)}
          aria-label={`Open ${astronomyPicture.title}`}
        >
          <img
            class="h-full w-full object-cover"
            src={astronomyPictureUrl(astronomyPicture)}
            alt={astronomyPicture.title}
          />
        </a>
        <div
          class="pointer-events-none absolute inset-x-0 bottom-0 bg-gradient-to-t from-black/95 via-black/65 to-transparent px-5 pb-5 pt-28 text-white sm:px-7 sm:pb-7"
        >
          <p
            class="m-0 text-[9px] font-semibold tracking-[0.22em] text-white/65 uppercase"
          >
            NASA astronomy picture of the day · {astronomyPictureDate(
              astronomyPicture.date,
            )}
          </p>
          <h2
            id="astronomy-picture-title"
            class="m-0 mt-2 text-2xl font-medium tracking-[-0.025em] text-white sm:text-3xl"
          >
            {astronomyPicture.title}
          </h2>
          <p
            class="m-0 mt-2 max-w-3xl line-clamp-3 text-xs leading-5 text-white/75 sm:text-sm"
          >
            {astronomyPicture.explanation}
          </p>
          <p class="m-0 mt-3 text-[10px] text-white/55">
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
