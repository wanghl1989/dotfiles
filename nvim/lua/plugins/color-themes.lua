return {
  -- {
  --   "catppuccin/nvim",
  --   name = "catppuccin",
  --   priority = 1000,
  --   opts = {},
  -- }
  --,
  {
    "Mofiqul/dracula.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      colors = {
        bg = "#181A26",
        fg = "#ddf7ff",
        selection = "#44475A",
        comment = "#6272A4",
        red = "#FF5555",
        orange = "#FFB86C",
        yellow = "#f1ff5e",
        green = "#4fe88f",
        purple = "#BD93F9",
        cyan = "#7cf8f7",
        pink = "#FF79C6",
        bright_red = "#FF6E6E",
        bright_green = "#50f872",
        bright_yellow = "#FFFFA5",
        bright_blue = "#D6ACFF",
        bright_magenta = "#FF92DF",
        bright_cyan = "#85E1FB",
        bright_white = "#F8F8F2",
        menu = "#0B0C16",
        visual = "#3E4452",
        gutter_fg = "#4B5263",
        nontext = "#3B4048",
        white = "#ABB2BF",
        black = "#191A21",
      },
      show_end_of_buffer = true, -- default false
      transparent_bg = true, -- default false
      -- set custom lualine background color
      lualine_bg_color = "#44475a", -- default nil
      -- set italic comment
      italic_comment = true, -- default false
      -- overrides the default highlights with table see `:h synIDattr`
      overrides = {},
    },
  },
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
      theme = {

        highlights = {
          Comment = { fg = "#898989", bg = "NONE", italic = true },
        },

        colors = {

          bg = "#0B0C16",
          dark = {
            -- bg_alt = "#1e2124",
            -- bg_highlight = "#3c4048",
            fg = "#ddf7ff",
            green = "#50f872",
            blue = "#829dd4",
            magenta = "#ff5ef1",
            cyan = "#7cf8f7",
          },
        },
      },
    },
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "dracula",
    },
  },
}
