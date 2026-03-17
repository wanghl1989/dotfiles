-- For `plugins/markview.lua` users.
local highlight_md_heading = "MyHighlightHeading"
vim.api.nvim_set_hl(0, highlight_md_heading, { bg = "#3e4452", fg = "#81a1c1" })

My_Render_Markdown_Opts = {
  render_modes = true, -- enable all modes
  heading = {
    sign = false,
    border = true,
    width = "block",
    below = "▔",
    above = "▁",
    left_pad = 0,
    right_pad = 4,
    position = "left",
    icons = {
      "█ ",
      "██ ",
      "███ ",
      "████ ",
      "█████ ",
      "██████ ",
    },
    backgrounds = { highlight_md_heading },
  },
  code = {
    width = "block",
    left_pad = 2,
    right_pad = 2,
    sign = false,
    left_margin = 2,
    position = "right", -- language indicator position
  },
}
return {
  "MeanderingProgrammer/render-markdown.nvim",
  ft = { "markdown", "quarto" },
  opts = My_Render_Markdown_Opts,
}
