return {
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        ["cpp"] = { "clang-format" },
        ["python"] = { "ruff_format", "ruff_fix", "ruff_organize_imports" },
        ["rust"] = { "rustfmt" }
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
