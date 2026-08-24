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
				typeCheckingMode = "basic",
				autoImportCompletions = false,
				diagnosticMode = "openFilesOnly",
				inlayHints = {
					variableTypes = true,
					functionReturnTypes = true,
				},
			},
		},
	},
})

-- vue_ls 3.x delegates TypeScript requests to vtsls. Mason installs the Vue
-- TypeScript plugin together with vue-language-server.
local vue_language_server_path = vim.fn.stdpath("data")
	.. "/mason/packages/vue-language-server/node_modules/@vue/language-server"

vim.lsp.config("vtsls", {
	settings = {
		vtsls = {
			tsserver = {
				globalPlugins = {
					{
						name = "@vue/typescript-plugin",
						location = vue_language_server_path,
						languages = { "vue" },
						configNamespace = "typescript",
					},
				},
			},
		},
	},
	filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact", "vue" },
})

vim.lsp.enable({
	"lua_ls",
	"basedpyright",
	"clangd",
	"ruff",
	"vue_ls",
	"vtsls",
	"jsonls",
})

vim.diagnostic.config({
	virtual_text = true,
	virtual_lines = false,
	float = { source = true },
})

local function find_containing_symbol(symbols, line)
	for _, symbol in ipairs(symbols) do
		local range = symbol.range or (symbol.location and symbol.location.range)
		if range and line >= range.start.line and line <= range["end"].line then
			local child = symbol.children and find_containing_symbol(symbol.children, line)
			return child or symbol
		end
	end
end

local function jump_to_current_symbol(bufnr, jump_to_end)
	local winid = vim.api.nvim_get_current_win()
	local line = vim.api.nvim_win_get_cursor(winid)[1] - 1
	local params = { textDocument = vim.lsp.util.make_text_document_params(bufnr) }

	vim.lsp.buf_request_all(bufnr, "textDocument/documentSymbol", params, function(responses)
		if not vim.api.nvim_win_is_valid(winid) or vim.api.nvim_win_get_buf(winid) ~= bufnr then
			return
		end

		for _, response in pairs(responses) do
			local symbol = find_containing_symbol(response.result or {}, line)
			local range = symbol and (symbol.range or (symbol.location and symbol.location.range))
			if range then
				local target = jump_to_end and range["end"] or range.start
				vim.api.nvim_win_set_cursor(winid, { target.line + 1, 0 })
				return
			end
		end
	end)
end

vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("SetupLSP", {}),
	callback = function(event)
		local client = assert(vim.lsp.get_client_by_id(event.data.client_id))
		local map_opts = { buffer = event.buf }

		-- Keep signature help available through Neovim's insert-mode <C-S>
		-- mapping, but prevent LSP trigger characters such as "(" and ","
		-- from opening it automatically.
		local signature_help = client.server_capabilities.signatureHelpProvider
		if signature_help then
			signature_help.triggerCharacters = {}
			signature_help.retriggerCharacters = {}
		end

		-- [inlay hint]
		if client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
			vim.keymap.set("n", "<leader>ch", function()
				vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
			end, { buffer = event.buf, desc = "LSP: Toggle Inlay Hints" })
		end

		-- [folding]
		if client:supports_method("textDocument/foldingRange") then
			for _, winid in ipairs(vim.fn.win_findbuf(event.buf)) do
				vim.wo[winid].foldexpr = "v:lua.vim.lsp.foldexpr()"
			end
		end

		-- Keep hover manual and explicit: it should only open after pressing K.
		vim.keymap.set(
			"n",
			"K",
			vim.lsp.buf.hover,
			vim.tbl_extend("force", map_opts, { desc = "LSP: Hover Documentation" })
		)

		-- Neovim already provides grn, gra, grr, gri and grt. Keep only
		-- additional mappings here, scoped to the attached buffer.
		vim.keymap.set(
			"n",
			"gd",
			vim.lsp.buf.definition,
			vim.tbl_extend("force", map_opts, { desc = "Goto Definition" })
		)
		vim.keymap.set(
			"n",
			"gI",
			vim.lsp.buf.implementation,
			vim.tbl_extend("force", map_opts, { desc = "Goto Implementation" })
		)
		vim.keymap.set(
			"n",
			"gy",
			vim.lsp.buf.type_definition,
			vim.tbl_extend("force", map_opts, { desc = "Goto Type Definition" })
		)
		vim.keymap.set(
			"n",
			"gD",
			vim.lsp.buf.declaration,
			vim.tbl_extend("force", map_opts, { desc = "Goto Declaration" })
		)
		vim.keymap.set(
			{ "n", "x" },
			"<leader>ca",
			vim.lsp.buf.code_action,
			vim.tbl_extend("force", map_opts, { desc = "Code action" })
		)
		vim.keymap.set("n", "[f", function()
			jump_to_current_symbol(event.buf, false)
		end, vim.tbl_extend("force", map_opts, { desc = "Jump to start of current function" }))
		vim.keymap.set("n", "]f", function()
			jump_to_current_symbol(event.buf, true)
		end, vim.tbl_extend("force", map_opts, { desc = "Jump to end of current function" }))
	end,
})

-- Neovim 0.12 provides :lsp enable/disable/restart/stop. Keep only commands
-- without a built-in equivalent.
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

vim.api.nvim_create_user_command("LspLog", function()
	vim.cmd.tabnew({ args = { vim.lsp.log.get_filename() } })
end, { desc = "Open the Neovim LSP client log" })
