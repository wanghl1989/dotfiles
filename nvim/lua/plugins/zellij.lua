-- return {
--   "swaits/zellij-nav.nvim",
--   lazy = false,
--
--   event = "VeryLazy",
--   keys = {
--     { "<c-h>", "<cmd>ZellijNavigateLeftTab<cr>", { silent = true, desc = "navigate left or tab" } },
--     { "<c-j>", "<cmd>ZellijNavigateDown<cr>", { silent = true, desc = "navigate down" } },
--     { "<c-k>", "<cmd>ZellijNavigateUp<cr>", { silent = true, desc = "navigate up" } },
--     { "<c-l>", "<cmd>ZellijNavigateRightTab<cr>", { silent = true, desc = "navigate right or tab" } },
--   },
--   opts = {},
-- }
return {
  "fresh2dev/zellij.vim",
  -- Pin version to avoid breaking changes.
  -- tag = '0.3.*',
  lazy = false,
}
