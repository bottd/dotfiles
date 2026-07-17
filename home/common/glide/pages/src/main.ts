import { mount } from "svelte";
import "virtual:uno.css";
import App from "./App.svelte";
import "./style.css";

mount(App, {
  target: document.getElementById("app")!,
});
