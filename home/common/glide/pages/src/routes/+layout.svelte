<script lang="ts">
  import type { Snippet } from "svelte";
  import "virtual:uno.css";

  let { children }: { children: Snippet } = $props();
</script>

{@render children()}
