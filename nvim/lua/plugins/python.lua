return {

  -- Configure LSP for Python
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        basedpyright = {
          settings = {
            basedpyright = {
              analysis = {
                typeCheckingMode = "off",
                autoImportCompletions = false,
                diagnosticMode = "workspace",
                inlayHints = {
                  variableTypes = true,
                  functionReturnTypes = true,
                },
              },
            },
          },
        },
        -- ruff_lsp = {
        --   on_attach = function(client, _)
        --     -- Disable hover in favor of Pyright
        --     client.server_capabilities.hoverProvider = false
        --   end,
        -- },
      },
    },
  },
  {
    "linux-cultist/venv-selector.nvim",
    dependencies = {
      "neovim/nvim-lspconfig",
      -- optional: you can also use fzf-lua, snacks, mini-pick instead.
    },
    ft = "python", -- Load when opening Python files
    keys = {
      { "<leader>vs", "<cmd>VenvSelect<cr>", { desc = "select python venv path" } }, -- Open picker on keymap
    },
    opts = {
      search_venv_managers = true,
      search_workspace = true,
      search = {}, -- if you add your own searches, they go here.
      options = {
        notify_user_on_venv_activation = true,
        debug = true,
      }, -- if you add plugin options, they go here.
    },
  },
}
