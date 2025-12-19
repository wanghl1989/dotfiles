return {
  {
    "stevearc/conform.nvim",
    opts = {
      format_on_save = {
        lsp_format = "never",
      },
      formatters_by_ft = {
        cpp = { "clang-format" },
        python = { "ruff" },
      },
    },
    keys = {
      {
        "<leader>fm",
        function()
          require("conform").format()
        end,
        desc = "Format File",
      },
    },
  },
}
