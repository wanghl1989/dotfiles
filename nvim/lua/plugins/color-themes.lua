return {
  {
    "scottmckendry/cyberdream.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      variant = "dark",
      transparent = false,
      saturation = 1,
      terminal_color = false,
      borderless_pickers = false,
      highlights = {
        Comment = { fg = "#7c8088", bg = "NONE", italic = true },
      },
      colors = {
        bg = "#181A26",
        dark = {
          bg_alt = "#1e2124",
          bg_highlight = "#3c5868",
          fg = "#ddf7ff",
          green = "#50f872",
          blue = "#829dd4",
          magenta = "#FF92DF",
          cyan = "#7cf8f7",
          pink = "#FF79C6",
          purple = "#ACA1CF",
        },
      },
      theme = {},
    },
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "cyberdream",
    },
  },
}
