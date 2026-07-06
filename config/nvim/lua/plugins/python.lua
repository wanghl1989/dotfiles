vim.pack.add({
	{ src = "https://github.com/linux-cultist/venv-selector.nvim" },
})

-- 立即初始化 venv-selector，确保它在 LSP 启动前注册好所有 autocmds
-- 这样缓存恢复可以在 basedpyright attach 之前触发
require("venv-selector").setup({
	search_venv_managers = true,
	search_workspace = true,
	search = {},
	options = {
		notify_user_on_venv_activation = true,
		debug = true,
		statusline_func = {
			lualine = function()
				local venv_path = require("venv-selector").venv()
				if not venv_path or venv_path == "" then
					return ""
				end

				local venv_name = vim.fn.fnamemodify(venv_path, ":t")
				if not venv_name then
					return ""
				end
				return venv_name
			end,
		},
	},
	-- 自定义 hook：切换 venv 后通知 basedpyright/ruff 更新 Python 路径
	-- 使用 workspace/didChangeConfiguration 而非重启整个 client，更快更可靠
	hooks = {
		function(python_path, env_type, bufnr)
			if not python_path or python_path == "" then
				return 0
			end

			local venv_dir = vim.fn.fnamemodify(python_path, ":h:h")
			local venv_name = vim.fn.fnamemodify(venv_dir, ":t")
			local venv_path = vim.fn.fnamemodify(venv_dir, ":h")

			vim.notify("󰆍 Venv switched: " .. venv_name, vim.log.levels.INFO, { title = "VenvSelect" })

			local new_settings = {
				python = {
					pythonPath = python_path,
					venv = venv_name,
					venvPath = venv_path,
				},
			}

			local count = 0
			local clients = vim.lsp.get_clients({ bufnr = bufnr or 0 })
			for _, client in ipairs(clients) do
				-- 只通知 Python LSP（basedpyright, pyright, ruff 等）
				local fts = client.config and client.config.filetypes
				if fts and vim.tbl_contains(fts, "python") then
					-- 更新 client 的 settings
					if client.settings then
						client.settings = vim.tbl_deep_extend("force", client.settings, new_settings)
					else
						client.config.settings = vim.tbl_deep_extend("force", client.config.settings or {}, new_settings)
					end
					-- 通知 LSP server 重新加载配置
					client:notify("workspace/didChangeConfiguration", { settings = nil })
					count = count + 1
				end
			end

			return count
		end,
	},
})

vim.keymap.set("n", "<leader>cp", "<cmd>:VenvSelect<cr>", { desc = "Select VirtualEnv" })
vim.keymap.set("n", "<leader>co", function()
	require("conform").format({ formatters = { "ruff_organize_imports" } })
end, { desc = "Organize imports" })
