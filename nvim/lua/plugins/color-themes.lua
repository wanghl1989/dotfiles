return {
  -- {
  --   "catppuccin/nvim",
  --   name = "catppuccin",
  --   priority = 1000,
  --   opts = {},
  -- },
  {
    "scottmckendry/cyberdream.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      transparent = true,
      saturation = 1,
      terminal_color = false,
      borderless_pickers = false,

      highlights = {
        Comment = { fg = "#898989", bg = "NONE", italic = true },
      },

      colors = {
        bg = "#0B0C16",
        fg = "#ddf7ff",
        green = "#50f872",
        blue = "#829dd4",
        magenta = "#ff5ef1",
        cyan = "#7cf8f7",
      },
    },
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "cyberdream",
    },
  },
}
