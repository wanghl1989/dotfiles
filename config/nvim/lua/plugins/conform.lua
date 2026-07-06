vim.pack.add({
	{ src = "https://github.com/stevearc/conform.nvim" },
})

vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
	group = vim.api.nvim_create_augroup("SetupConform", { clear = true }),
	once = true,
	callback = function()
		require("conform").setup({
			formatters_by_ft = {
				lua = { "stylua" },
				-- Conform will run multiple formatters sequentially
				python = { "ruff_fix", "ruff_format", "ruff_organize_imports" },
				-- You can customize some of the format options for the filetype (:help conform.format)
				rust = { "rustfmt", lsp_format = "fallback" },
				-- Conform will run the first available formatter
				javascript = { "prettierd", "prettier", stop_after_first = true },
			},
		})

		-- 格式化
		vim.keymap.set("n", "<leader>cf", function()
			require("conform").format({ bufnr = 0 })
		end, { desc = "Format Code" })

		vim.keymap.set("n", "<leader>fm", function()
			require("conform").format({ bufnr = 0 })
		end, { desc = "Format Code" })
	end,
})

----------------------
-- 自动命令 --
----------------------
-- 保存前自动格式化
-- vim.api.nvim_create_autocmd("BufWritePre", {
-- 	pattern = "*",
-- 	callback = function(buf)
-- 		require("conform").format({ bufnr = buf })
-- 	end,
-- })
