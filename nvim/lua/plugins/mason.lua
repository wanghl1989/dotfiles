return {
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {
        "ruff",      -- Python linting and formatting
        "sqlfluff",  -- SQL linting and formatting
        "harper-ls", -- Spelling and grammar checking
      },
    },
  },
  {
    "mason-org/mason-lspconfig.nvim",
    opts = {},
    dependencies = {
      { "mason-org/mason.nvim", opts = {} },
      "neovim/nvim-lspconfig",
    },
  },
}
