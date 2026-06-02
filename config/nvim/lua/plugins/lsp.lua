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
		vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Goto Definition" })
		vim.keymap.set("n", "gr", vim.lsp.buf.references, { desc = "References", nowait = true })
		vim.keymap.set("n", "gI", vim.lsp.buf.implementation, { desc = "Goto Implementation" })
		vim.keymap.set("n", "gy", vim.lsp.buf.type_definition, { desc = "Goto T[y]pe Definition" })
		vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { desc = "Goto Declaration" })
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

		-- LSP 诊断显示
		vim.diagnostic.config({
			virtual_text = true, -- 行内文本提示
			virtual_lines = false, -- 虚拟行提示（可选）
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
		client:stop(true)
	end

	vim.defer_fn(function()
		vim.cmd("edit")
	end, 100)
end, { desc = "Restart LSP clients for current buffer" })

vim.api.nvim_create_user_command("LspStatus", function()
	local clients = vim.lsp.get_clients()
	local lines = {}
	local function dump_yaml(tbl, indent)
		indent = indent or 0
		local res = {}
		local pad = string.rep(" ", indent)

		for k, v in pairs(tbl) do
			local key = tostring(k)
			if v == vim.NIL then
				table.insert(res, pad .. key .. ": null")
			elseif type(v) == "boolean" then
				table.insert(res, pad .. key .. ": " .. tostring(v))
			elseif type(v) == "number" then
				table.insert(res, pad .. key .. ": " .. tostring(v))
			elseif type(v) == "string" then
				table.insert(res, pad .. key .. ': "' .. v .. '"')
			elseif type(v) == "table" then
				-- 判断是否为数组
				local is_arr = true
				local max_key = 0
				for kk in pairs(v) do
					if type(kk) ~= "number" or kk < 1 or kk ~= math.floor(kk) then
						is_arr = false
						break
					end
					max_key = math.max(max_key, kk)
				end

				table.insert(res, pad .. key .. ":")
				local sub = indent + 2
				if is_arr then
					for _, item in ipairs(v) do
						local sp = string.rep(" ", sub)
						if type(item) == "table" then
							table.insert(res, sp .. "-")
							vim.list_extend(res, dump_yaml({ [""] = item }, sub + 2))
						elseif item == vim.NIL then
							table.insert(res, sp .. "- null")
						elseif type(item) == "string" then
							table.insert(res, sp .. '- "' .. item .. '"')
						else
							table.insert(res, sp .. "- " .. tostring(item))
						end
					end
				else
					vim.list_extend(res, dump_yaml(v, sub))
				end
			else
				table.insert(res, pad .. key .. ": <" .. type(v) .. ">")
			end
		end
		return res
	end

	-- 无LSP客户端时直接提示
	if #clients == 0 then
		lines = { "󰅚 No LSP clients attached" }
	else
		-- 标题行
		table.insert(lines, "󰒋 LSP Status active now")
		table.insert(
			lines,
			"─────────────────────────────────"
		)
		table.insert(lines, "")

		-- 遍历所有客户端，拼接信息
		for i, client in ipairs(clients) do
			table.insert(lines, string.format("󰌘 Client %d: %s (ID: %d)", i, client.name, client.id))
			table.insert(lines, "  Root: " .. (client.root_dir or "N/A"))
			table.insert(lines, "  Settings:")
			local sett = client.settings or {}
			if vim.tbl_isempty(sett) then
				table.insert(lines, "    <empty>")
			else
				-- 生成yaml，整体再缩进2空格
				local yaml_list = dump_yaml(sett, 4)
				vim.list_extend(lines, yaml_list)
			end

			-- 收集支持的功能
			local caps = client.server_capabilities
			local features = {}
			if caps then
				if caps.completionProvider then
					table.insert(features, "completion")
				end
				if caps and caps.hoverProvider then
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
			end

			table.insert(lines, "  Features: " .. table.concat(features, ","))
			table.insert(lines, "")
		end
	end

	-- ===================== 悬浮窗口核心 =====================
	-- 创建临时缓冲区
	local float_buf = vim.api.nvim_create_buf(false, true)
	-- 计算窗口尺寸（自适应内容+屏幕大小）
	local width = math.floor(vim.o.columns * 0.5)
	local height = math.min(#lines + 2, vim.o.lines - 10)
	local row = math.floor((vim.o.lines - height) / 2)
	local col = math.floor((vim.o.columns - width) / 2)

	-- 创建悬浮窗口
	vim.api.nvim_open_win(float_buf, true, {
		relative = "editor",
		row = row,
		col = col,
		width = width,
		height = height,
		style = "minimal", -- 无多余UI
		border = "rounded", -- 圆角边框
		title = " LSP Status ",
		title_pos = "center",
	})

	-- 写入所有内容
	vim.api.nvim_buf_set_lines(float_buf, 0, -1, false, lines)

	-- 窗口设置：只读 + 关闭自动销毁
	vim.bo[float_buf].modifiable = false
	vim.bo[float_buf].bufhidden = "wipe"
	-- 按键 q 关闭窗口
	vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = float_buf, silent = true })
end, { desc = "Show brief LSP status in float window" })

-- Lsp Log
vim.api.nvim_create_user_command("LspLog", function()
	vim.cmd(string.format("tabnew %s", vim.lsp.log.get_filename()))
end, {
	desc = "Opens the Nvim LSP client log.",
})
