vim.pack.add({
	{ src = "https://github.com/neovim/nvim-lspconfig" },
	{ src = "https://github.com/mason-org/mason.nvim" },
})

require("mason").setup()

vim.lsp.config("*", {
	capabilities = {
		workspace = {
			fileOperations = {
				didRename = true,
				willRename = true,
			},
		},
	},
})

vim.lsp.config("lua_ls", {
	settings = {
		Lua = {
			runtime = { version = "LuaJIT" }, -- Neovim使用LuaJIT
			diagnostics = {
				globals = { "vim" }, -- 识别 Neovim 全局变量 vim
			},
			workspace = {
				checkThirdParty = false, -- 关闭第三方库提示
				library = vim.api.nvim_get_runtime_file("", true), -- 加载Neovim源码
			},
			telemetry = { enable = false }, -- 关闭遥测
		},
	},
})

vim.lsp.config("basedpyright", {
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
})

vim.lsp.enable({
	"tree-sitter-cli",
	"lua_ls",
	"basedpyright",
	"clangd",
	"ruff",
	"vue-language-server",
	"prettier",
	"json-lsp",
})

-- LSP 诊断显示
vim.diagnostic.config({ virtual_text = true }) -- 行内文本提示
-- vim.diagnostic.config({ virtual_lines = true }) -- 虚拟行提示（可选）

vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("SetupLSP", {}),
	callback = function(event)
		local client = assert(vim.lsp.get_client_by_id(event.data.client_id))

		-- [inlay hint]
		if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
			vim.keymap.set("n", "<leader>ch", function()
				vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
			end, { buffer = event.buf, desc = "LSP: Toggle Inlay Hints" })
		end

		-- [folding]
		if client and client:supports_method("textDocument/foldingRange") then
			local win = vim.api.nvim_get_current_win()
			vim.wo[win][0].foldexpr = "v:lua.vim.lsp.foldexpr()"
		end

		-- [keymaps]
		vim.keymap.set("n", "<leader>cf", vim.lsp.buf.format)
		-- vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Goto Definition" })
		-- vim.keymap.set("n", "gr", vim.lsp.buf.references, { desc = "References", nowait = true })
		-- vim.keymap.set("n", "gI", vim.lsp.buf.implementation, { desc = "Goto Implementation" })
		-- vim.keymap.set("n", "gy", vim.lsp.buf.type_definition, { desc = "Goto T[y]pe Definition" })
		-- vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { desc = "Goto Declaration" })
		vim.keymap.set("n", "K", function()
			return vim.lsp.buf.hover()
		end, { desc = "Hover" })
		vim.keymap.set({ "n", "x" }, "<leader>ca", vim.lsp.buf.code_action, { desc = "Code action" })

		local function jump_to_current_function_start()
			local params = { textDocument = vim.lsp.util.make_text_document_params() }
			local responses = vim.lsp.buf_request_sync(0, "textDocument/documentSymbol", params, 1000)
			if not responses then
				return
			end

			local pos = vim.api.nvim_win_get_cursor(0)
			local line = pos[1] - 1

			local function find_symbol(symbols)
				for _, s in ipairs(symbols) do
					local range = s.range or (s.location and s.location.range)
					if range and line >= range.start.line and line <= range["end"].line then
						if s.children then
							local child = find_symbol(s.children)
							if child then
								return child
							end
						end
						return s
					end
				end
			end

			for _, resp in pairs(responses) do
				local sym = find_symbol(resp.result or {})
				if sym and sym.range then
					vim.api.nvim_win_set_cursor(0, { sym.range.start.line + 1, 0 })
					return
				end
			end
		end
		vim.keymap.set("n", "[f", jump_to_current_function_start, { desc = "Jump to start of current function" })

		local function jump_to_current_function_end()
			local params = { textDocument = vim.lsp.util.make_text_document_params() }
			local responses = vim.lsp.buf_request_sync(0, "textDocument/documentSymbol", params, 1000)
			if not responses then
				return
			end

			local pos = vim.api.nvim_win_get_cursor(0)
			local line = pos[1] - 1

			local function find_symbol(symbols)
				for _, s in ipairs(symbols) do
					local range = s.range or (s.location and s.location.range)
					if range and line >= range.start.line and line <= range["end"].line then
						if s.children then
							local child = find_symbol(s.children)
							if child then
								return child
							end
						end
						return s
					end
				end
			end

			for _, resp in pairs(responses) do
				local sym = find_symbol(resp.result or {})
				if sym and sym.range then
					-- jump to end of the symbol
					vim.api.nvim_win_set_cursor(0, { sym.range["end"].line + 1, 0 })
					return
				end
			end
		end

		vim.keymap.set("n", "]f", jump_to_current_function_end, { desc = "Jump to end of current function" })
		vim.diagnostic.config({
			virtual_text = true,
			virtual_lines = false,
			float = { source = true },
		})
	end,
})

-- LspRestart: Restart LSP clients for current buffer
vim.api.nvim_create_user_command("LspInfo", ":checkhealth lsp", { desc = "Check LSP Info" })

-- LspRestart: Restart LSP clients for current buffer
vim.api.nvim_create_user_command("LspRestart", function()
	local bufnr = vim.api.nvim_get_current_buf()
	local clients = vim.lsp.get_clients({ bufnr = bufnr })

	if #clients == 0 then
		vim.notify("No LSP clients attached to restart", vim.log.levels.WARN)
		return
	end

	for _, client in ipairs(clients) do
		vim.notify("Restarting " .. client.name, vim.log.levels.INFO)
		vim.lsp.stop_client(client.id)
	end

	vim.defer_fn(function()
		vim.cmd("edit")
	end, 100)
end, { desc = "Restart LSP clients for current buffer" })

-- LspStatus: Show brief LSP status
vim.api.nvim_create_user_command("LspStatus", function()
	local bufnr = vim.api.nvim_get_current_buf()
	local clients = vim.lsp.get_clients({ bufnr = bufnr })

	if #clients == 0 then
		print("󰅚 No LSP clients attached")
		return
	end

	print("󰒋 LSP Status for buffer " .. bufnr .. ":")
	print("─────────────────────────────────")

	for i, client in ipairs(clients) do
		print(string.format("󰌘 Client %d: %s (ID: %d)", i, client.name, client.id))
		print("  Root: " .. (client.config.root_dir or "N/A"))
		print("  Filetypes: " .. table.concat(client.config.filetypes or {}, ", "))

		local caps = client.server_capabilities
		local features = {}
		if caps.completionProvider then
			table.insert(features, "completion")
		end
		if caps.hoverProvider then
			table.insert(features, "hover")
		end
		if caps.definitionProvider then
			table.insert(features, "definition")
		end
		if caps.referencesProvider then
			table.insert(features, "references")
		end
		if caps.renameProvider then
			table.insert(features, "rename")
		end
		if caps.codeActionProvider then
			table.insert(features, "code_action")
		end
		if caps.documentFormattingProvider then
			table.insert(features, "formatting")
		end

		print("  Features: " .. table.concat(features, ", "))
		print("")
	end
end, { desc = "Show brief LSP status" })

-- lsp
local api, lsp = vim.api, vim.lsp
api.nvim_create_user_command("LspLog", function()
	vim.cmd(string.format("tabnew %s", lsp.get_log_path()))
end, {
	desc = "Opens the Nvim LSP client log.",
})
