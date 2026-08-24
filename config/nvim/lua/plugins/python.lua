vim.pack.add({
	{ src = "https://github.com/linux-cultist/venv-selector.nvim" },
})

local function basedpyright_clients(bufnr)
	return vim.lsp.get_clients({ bufnr = bufnr, name = "basedpyright" })
end

local function sync_basedpyright(python_path, bufnr, restart)
	if type(python_path) ~= "string" or python_path == "" then
		return 0
	end
	if not vim.api.nvim_buf_is_valid(bufnr) then
		return 0
	end

	local clients = basedpyright_clients(bufnr)
	if #clients == 0 then
		return 0
	end

	local needs_update = vim.iter(clients):any(function(client)
		return vim.tbl_get(client.settings, "python", "pythonPath") ~= python_path
	end)
	if not needs_update then
		return #clients
	end

	vim.schedule(function()
		if not vim.api.nvim_buf_is_valid(bufnr) then
			return
		end

		vim.api.nvim_buf_call(bufnr, function()
			-- This buffer-local command is provided by nvim-lspconfig's official
			-- basedpyright config. It updates pythonPath and notifies the server.
			if vim.fn.exists(":LspPyrightSetPythonPath") ~= 2 then
				return
			end
			vim.api.nvim_cmd({ cmd = "LspPyrightSetPythonPath", args = { python_path } }, {})

			if restart then
				-- Neovim 0.12's official command restarts the client with its
				-- updated config and reattaches the existing buffers.
				vim.api.nvim_cmd({ cmd = "lsp", args = { "restart", "basedpyright" } }, {})
			end
		end)
	end)

	return #clients
end

-- Initialize before LSPs are enabled so cached environments and newly attached
-- basedpyright clients can converge regardless of which one becomes ready first.
require("venv-selector").setup({
	search_venv_managers = true,
	search_workspace = true,
	search = {},
	hooks = {
		function(python_path, _, bufnr)
			return sync_basedpyright(python_path, bufnr or vim.api.nvim_get_current_buf(), true)
		end,
	},
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
})

vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("SyncPythonVenvLsp", { clear = true }),
	callback = function(event)
		local client = vim.lsp.get_client_by_id(event.data.client_id)
		if not client or client.name ~= "basedpyright" or vim.bo[event.buf].filetype ~= "python" then
			return
		end

		vim.schedule(function()
			if not vim.api.nvim_buf_is_valid(event.buf) then
				return
			end

			local selector = require("venv-selector")
			local venv = require("venv-selector.venv")
			local project_root = require("venv-selector.project_root").key_for_buf(event.buf)
			local python_path = selector.python()

			if python_path and venv.active_project_root() == project_root then
				sync_basedpyright(python_path, event.buf, true)
				return
			end

			-- If the cache became available after the initial buffer events, retry
			-- now that basedpyright has supplied a stable project root.
			require("venv-selector.cached_venv").retrieve(event.buf)
		end)
	end,
})

vim.keymap.set("n", "<leader>cp", "<cmd>VenvSelect<cr>", { desc = "Select VirtualEnv" })
vim.keymap.set("n", "<leader>co", function()
	require("conform").format({ formatters = { "ruff_organize_imports" } })
end, { desc = "Organize imports" })
