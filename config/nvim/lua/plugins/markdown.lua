-- For `plugins/markview.lua` users.
local highlight_md_heading = "MyHighlightHeading"
vim.api.nvim_set_hl(0, highlight_md_heading, { bg = "#3e4452", fg = "#81a1c1" })

My_Render_Markdown_Opts = {
  render_modes = true, -- enable all modes
  heading = {
    sign = true,
    border = false,
    width = "block",
    below = "▔",
    above = "▁",
    left_pad = 0,
    right_pad = 4,
    position = "left",

    backgrounds = {
      "MiniStatusLineModeNormal",
      "MiniStatusLineModeInsert",
      "MiniStatusLineModeReplace",
      "MiniStatusLineModeVisual",
      "MiniStatusLineModeCommand",
      "MiniStatusLineModeOther",
    },
    icons = {
      " ",
      " ",
      " ",
      " ",
      " ",
      " ",
    },
  },
  code = {
    width = "block",
    left_pad = 0,
    right_pad = 2,
    sign = false,
    left_margin = 2,
    position = "right", -- language indicator position
  },

  bullet = {
    enabled = true,
    render_modes = false,
    icons = { "", "", "", "" },
  },
  checkbox = {
    enabled = true,
    render_modes = false,
    bullet = false,
    left_pad = 0,
    right_pad = 1,
    unchecked = {
      icon = "󰄱 ",
      highlight = "RenderMarkdownUnchecked",
      scope_highlight = nil,
    },
    checked = {
      icon = "󰱒 ",
      highlight = "RenderMarkdownChecked",
      scope_highlight = nil,
    },
    custom = {
      todo = { raw = "[-]", rendered = "󰥔 ", highlight = "RenderMarkdownTodo", scope_highlight = nil },
    },
    scope_priority = nil,
  },
  pipe_table = {
    -- preset = 'round',
    alignment_indicator = "─",
    border = { "╭", "┬", "╮", "├", "┼", "┤", "╰", "┴", "╯", "│", "─" },
  },
  link = {
    render_modes = false,
    wiki = { icon = " ", highlight = "RenderMarkdownWikiLink", scope_highlight = "RenderMarkdownWikiLink" },
    image = " ",
    custom = {
      github = { pattern = "github", icon = " " },
      cern = { pattern = "cern.ch", icon = " " },
    },
    hyperlink = " ",
  },
  anti_conceal = {
    disabled_modes = { "n" },
    ignore = {
      bullet = false, -- render bullet in insert mode
      head_border = true,
      head_background = true,
    },
  },
  -- https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/509
  win_options = { concealcursor = { rendered = "nvc" } },

  completions = {
    blink = { enabled = true },
    lsp = { enabled = true },
  },
}
return {
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown", "quarto" },
    opts = My_Render_Markdown_Opts,
  },
  {
    "3rd/image.nvim",
    opts = {
      backend = "kitty",
      processor = "magick_cli",
      integrations = {
        markdown = {
          enabled = true,
          clear_in_insert_mode = true,
        },
      },
    },
  },
}
