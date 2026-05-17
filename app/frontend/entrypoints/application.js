import "../styles/application.css";
import { Elm } from "../elm/StatusPulse.elm";

document.addEventListener("DOMContentLoaded", () => {
  document.querySelectorAll("[data-elm-status-pulse]").forEach((node) => {
    Elm.StatusPulse.init({
      node,
      flags: {
        accountName: node.dataset.accountName || "Demo account"
      }
    });
  });
});

