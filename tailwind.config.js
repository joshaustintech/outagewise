import daisyui from "daisyui";

export default {
  content: [
    "./app/views/**/*.erb",
    "./app/helpers/**/*.rb",
    "./app/frontend/**/*.js",
    "./app/frontend/**/*.elm"
  ],
  theme: {
    extend: {}
  },
  daisyui: {
    themes: ["light"]
  },
  plugins: [daisyui]
};
