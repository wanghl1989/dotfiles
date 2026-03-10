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
        -- 核心：屏蔽冗余日志，彻底解决退出报错
        cmd = { "taplo", "lsp", "stdio" },
        -- 核心：屏蔽 taplo 所有无用日志，彻底解决退出报错
        on_attach = function(client)
          -- 关闭客户端日志监听
          client.stop = function()
            vim.lsp.client.stop(client, true)
          end
        end,
      },
    },
  },
}
