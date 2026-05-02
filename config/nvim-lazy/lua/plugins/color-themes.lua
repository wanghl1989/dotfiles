vim.g.gruvbox_baby_function_style = "NONE"
vim.g.gruvbox_baby_keyword_style = "NONE"

-- Each highlight group must follow the structure:
-- ColorGroup = {fg = "foreground color", bg = "background_color", style = "some_style(:h attr-list)"}
-- See also :h highlight-guifg
-- Example:
vim.g.gruvbox_baby_highlights = { Normal = { fg = "#123123", bg = "NONE", style = "underline" } }

-- Enable telescope theme
vim.g.gruvbox_baby_telescope_theme = 1

-- Enable transparent mode
vim.g.gruvbox_baby_transparent_mode = 1

return {
  {
    "scottmckendry/cyberdream.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      variant = "dark",
      transparent = true,
      saturation = 1,
      terminal_color = false,
      borderless_pickers = false,
      highlights = {
        Comment = { fg = "#7c8088", bg = "NONE", italic = false },
      },
      colors = {
        -- bg = "#181A26",
        fg = "#d2f8d2",
        dark = {
          -- bg_alt = "#1e2124",
          bg_highlight = "#3c5868",
          green = "#4fe88f",
          blue = "#7cf8f7",
          magenta = "#ff92df",
          cyan = "#5ea1ff",
          pink = "#FF79C6",
          purple = "#cba6f7",
          orange = "#ffbd5e",
        },
      },
      theme = {},
    },
  },
  {
    "ellisonleao/gruvbox.nvim",
    priority = 1000,
    config = true,
    opts = {
      italic = {
        strings = false,
        emphasis = false,
        comments = false,
        operators = false,
        folds = false,
      },
      contrast = "hard",
      transparent_mode = true
    },
  },

  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "gruvbox",
    },
  },
}
