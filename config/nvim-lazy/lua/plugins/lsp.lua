return {
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
      taplo = {
        cmd = { "taplo", "lsp", "stdio" },
        on_attach = function(client)
          client.stop = function()
            vim.lsp.client.stop(client, true)
          end
        end,
      },
    },
  },
}
