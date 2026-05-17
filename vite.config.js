import { defineConfig } from "vite";
import { execFileSync } from "node:child_process";
import { mkdtempSync, readFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";

function elmPlugin() {
  return {
    name: "outagewise-elm",
    enforce: "pre",
    load(id) {
      if (!id.endsWith(".elm")) return null;

      const outputPath = join(mkdtempSync(join(tmpdir(), "outagewise-elm-")), "module.js");

      execFileSync(
        "node_modules/.bin/elm",
        ["make", id, "--output", outputPath, "--optimize"],
        { stdio: "inherit" }
      );

      const compiled = readFileSync(outputPath, "utf8").replace(/\}\(this\)\);\s*$/, "}(globalThis));");

      return `${compiled}\nconst Elm = globalThis.Elm;\nexport { Elm };\n`;
    }
  };
}

export default defineConfig({
  publicDir: false,
  plugins: [elmPlugin()],
  build: {
    emptyOutDir: true,
    manifest: false,
    outDir: "app/assets/builds/vite",
    rollupOptions: {
      input: "app/frontend/entrypoints/application.js",
      output: {
        assetFileNames: "application[extname]",
        entryFileNames: "application.js"
      }
    }
  }
});
