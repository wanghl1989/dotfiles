return {
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        cpp = { "clang-format" },
        python = { "ruff", "black" },
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
