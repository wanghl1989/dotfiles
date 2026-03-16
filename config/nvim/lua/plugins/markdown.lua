-- For `plugins/markview.lua` users.
local highlight_md_heading = "MyHighlightHeading"
vim.api.nvim_set_hl(0, highlight_md_heading, { bg = "#3e4452", fg = "#81a1c1" })

My_Render_Markdown_Opts = {
  render_modes = true, -- enable all modes
  heading = {
    width = { "full", "block" },
    border = true,
    border_virtual = true,
    border_prefix = true,
    min_width = 40,
    sign = false,
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
