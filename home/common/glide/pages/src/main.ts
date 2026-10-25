import { mount } from "svelte";
import App from "./App.svelte";
import "./palette.css";
import "./style.css";

mount(App, {
  target: document.getElementById("app")!,
});
