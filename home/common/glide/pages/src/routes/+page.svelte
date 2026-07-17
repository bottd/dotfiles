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

  const hackerNewsApi = "https://hacker-news.firebaseio.com/v0";
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
  let controller: AbortController;

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
    controller?.abort();
    controller = new AbortController();
    loading = true;
    error = false;

    try {
      const topResponse = await fetch(`${hackerNewsApi}/topstories.json`, {
        signal: controller.signal,
      });
      if (!topResponse.ok) throw new Error("Could not load Hacker News");

      const ids = (await topResponse.json()) as number[];
      const responses = await Promise.all(
        ids.slice(0, 8).map((id) =>
          fetch(`${hackerNewsApi}/item/${id}.json`, {
            signal: controller.signal,
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

  onMount(() => {
    loadStories();
    return () => controller?.abort();
  });
</script>

<svelte:head>
  <title>New tab</title>
  <meta
    name="description"
    content="Glide new tab with Hacker News, Wikipedia, and media shortcuts"
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
        <div class="browser-bar" aria-hidden="true">
          <span class="browser-dot"></span>
          <span class="browser-dot"></span>
          <span class="browser-dot"></span>
          <span class="browser-address">news.ycombinator.com</span>
        </div>

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
            <div>
              <p
                class="widget-kicker m-0 text-[9px] font-semibold tracking-[0.22em] text-base04 uppercase"
              >
                Reference
              </p>
              <h2
                id="wiki-title"
                class="m-0 mt-1 text-base font-medium text-base07"
              >
                Wikipedia
              </h2>
            </div>
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
            <p
              class="widget-kicker m-0 text-[9px] font-semibold tracking-[0.22em] text-base04 uppercase"
            >
              Channels
            </p>
            <h2
              id="media-title"
              class="m-0 mt-1 text-base font-medium text-base07"
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
      class="widget mt-4 overflow-hidden"
      aria-label="Counterscale analytics"
    >
      <div class="browser-bar">
        <span class="browser-dot" aria-hidden="true"></span>
        <span class="browser-dot" aria-hidden="true"></span>
        <span class="browser-dot" aria-hidden="true"></span>
        <a
          class="browser-address flex-1 text-inherit no-underline"
          href="https://a.drake.dev/dashboard"
        >
          a.drake.dev/dashboard
        </a>
        <a
          class="px-1 text-xs text-base04 no-underline hover:text-base07"
          href="https://a.drake.dev/dashboard"
          aria-label="Open Counterscale analytics"
        >
          ↗
        </a>
      </div>
      <iframe
        class="block h-[520px] w-full border border-base03 border-t-0 bg-white sm:h-[640px]"
        src="https://a.drake.dev/dashboard"
        title="Counterscale analytics"
        referrerpolicy="no-referrer"
      ></iframe>
    </section>
  </div>
</main>
