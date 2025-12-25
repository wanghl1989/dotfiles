return {
  -- {
  --   "catppuccin/nvim",
  --   name = "catppuccin",
  --   priority = 1000,
  --   opts = {},
  -- }
  --,

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
        Comment = { fg = "#898989", bg = "NONE", italic = true },
      },

      colors = {
        bg = "#282A36",
        dark = {
          bg_alt = "#1e2124",
          bg_highlight = "#3c4048",
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
