local opt = vim.opt

opt.autowrite = true -- Enable auto write
-- only set clipboard if not in ssh, to make sure the OSC 52
-- integration works automatically.
-- opt.clipboard = vim.env.SSH_CONNECTION and "" or "unnamedplus" -- Sync with system clipboard
-- 检测当前是否为 SSH 环境
local is_ssh = vim.env.SSH_TTY ~= nil or vim.env.SSH_CONNECTION ~= nil

if is_ssh then
  -- SSH 环境下使用 OSC52 作为系统剪贴板提供者
  vim.g.clipboard = {
    name = 'OSC 52',
    copy = {
      ['+'] = require('vim.ui.clipboard.osc52').copy('+'),
      ['*'] = require('vim.ui.clipboard.osc52').copy('*'),
    },
    -- OSC52 不支持从本地读取剪贴板，这里降级使用内部无名寄存器
    paste = {
      ['+'] = function() return vim.split(vim.fn.getreg('"'), '\n') end,
      ['*'] = function() return vim.split(vim.fn.getreg('"'), '\n') end,
    },
  }
end

-- 让 y 操作默认同步到系统剪贴板
vim.opt.clipboard:append('unnamedplus')

opt.completeopt = 'menu,menuone,fuzzy,noinsert'
opt.conceallevel = 2 -- Hide * markup for bold and italic, but not markers with substitutions
opt.confirm = true -- Confirm to save changes before exiting modified buffer
opt.cursorline = true -- Enable highlighting of the current line
opt.smarttab = true

opt.formatoptions = "jcroqlnt" -- tcqj
opt.grepformat = "%f:%l:%c:%m"
opt.grepprg = "rg --vimgrep"
opt.ignorecase = true -- Ignore case
opt.inccommand = "nosplit" -- preview incremental substitute
opt.laststatus = 3 -- global statusline
opt.linebreak = true -- Wrap lines at convenient points
opt.list = false -- Show some invisible characters (tabs...
opt.mouse = "a" -- Enable mouse mode
opt.number = true -- Print line number
opt.pumblend = 10 -- Popup blend
opt.pumheight = 10 -- Maximum number of entries in a popup
opt.relativenumber = true -- Relative line numbers
opt.ruler = false -- Disable the default ruler
opt.scrolloff = 4 -- Lines of context
opt.sessionoptions = { "buffers", "curdir", "tabpages", "winsize", "help", "globals", "skiprtp", "folds" }
opt.shiftround = true -- Round indent
opt.shortmess:append({ W = true, I = true, c = true, C = true })
opt.showmode = false -- Dont show mode since we have a statusline
opt.sidescrolloff = 8 -- Columns of context
opt.signcolumn = "yes" -- Always show the signcolumn, otherwise it would shift the text each time
opt.smartcase = true -- Don't ignore case with capitals
opt.smartindent = true -- Insert indents automatically
opt.smoothscroll = true
opt.spelllang = { "en" }
opt.splitbelow = true -- Put new windows below current
opt.splitkeep = "screen"
opt.splitright = true -- Put new windows right of current
opt.termguicolors = true -- True color support
opt.timeoutlen = vim.g.vscode and 1000 or 300 -- Lower than default (1000) to quickly trigger which-key
opt.undofile = true
opt.undolevels = 10000
opt.updatetime = 200 -- Save swap file and trigger CursorHold
opt.swapfile = false -- Save swap file or not
opt.virtualedit = "block" -- Allow cursor to move where there is no text in visual block mode
opt.wildmode = "longest:full,full" -- Command-line completion mode
opt.winminwidth = 5 -- Minimum window width
opt.winborder = "rounded"
opt.wrap = false -- Disable line wrap

-- Fix markdown indentation settings
vim.g.markdown_recommended_style = 0
vim.o.jumpoptions = "stack" -- or "view"

-- 禁止自动注释续行（通过 FileType autocmd 确保 filetype 插件重新设置后也能移除）
vim.api.nvim_create_autocmd("FileType", {
	pattern = "*",
	callback = function()
		vim.opt.formatoptions:remove({ "c", "r", "o" })
	end,
})

local indent_configs = {
	-- 2 空格缩进组
	{
		size = 2,
		expand = true,
		fts = { "json", "jsonc", "yaml", "markdown", "sh", "toml", "sql", "gitcommit", "javascript", "typescript" },
	},
	-- 4 空格缩进组
	{
		size = 4,
		expand = true,
		fts = { "c", "cpp", "python", "lua", "rust" },
	},
	-- 4 物理 Tab 组
	{
		size = 4,
		expand = false,
		fts = { "go" },
	},
}
-- 全局默认值
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

local indent_group = vim.api.nvim_create_augroup("User_LanguagesIndent", { clear = true })
for _, config in ipairs(indent_configs) do
	vim.api.nvim_create_autocmd("FileType", {
		pattern = config.fts, -- Neovim 的 pattern 原生支持直接传入 table: { 'json', 'yaml' }
		group = indent_group,
		callback = function()
			vim.opt_local.tabstop = config.size
			vim.opt_local.shiftwidth = config.size
			vim.opt_local.softtabstop = config.size
			vim.opt_local.expandtab = config.expand
		end,
	})
end

-- folding
vim.o.foldcolumn = "0"
vim.o.foldlevel = 99
vim.o.foldlevelstart = 99
vim.o.foldenable = false
vim.o.foldmethod = "expr"
vim.o.fillchars = "eob: ,fold: ,foldopen:,foldsep: ,foldclose:"
vim.o.foldexpr = "v:lua.vim.treesitter.foldexpr()"

local function fold_virt_text(result, start_text, lnum)
	local text = ""
	local hl
	for i = 1, #start_text do
		local char = start_text:sub(i, i)
		local new_hl = "@text"

		-- if semantic tokens unavailable, use treesitter hl
		local sem_tokens = vim.lsp.semantic_tokens.get_at_pos(0, lnum, i)
		if sem_tokens and #sem_tokens > 0 then
			new_hl = "@" .. sem_tokens[1].type
		else
			local captures = vim.treesitter.get_captures_at_pos(0, lnum, i - 1)
			if #captures > 0 then
				local top = captures[1]
				local top_priority = (top.metadata and tonumber(top.metadata.priority)) or 0
				for _, cap in ipairs(captures) do
					local raw_prio = cap.metadata and cap.metadata.priority
					local prio = tonumber(raw_prio) or 0
					if prio > top_priority then
						top = cap
						top_priority = prio
					end
				end
				new_hl = "@" .. top.capture
			end
		end

		if new_hl then
			if new_hl ~= hl then
				table.insert(result, { text, hl })
				text = ""
				hl = nil
			end
			text = text .. char
			hl = new_hl
		else
			text = text .. char
		end
	end
	table.insert(result, { text, hl })
end
function _G.custom_foldtext()
	local start_text = vim.fn.getline(vim.v.foldstart):gsub("\t", string.rep(" ", vim.o.tabstop))
	local nline = vim.v.foldend - vim.v.foldstart
	local result = {}
	fold_virt_text(result, start_text, vim.v.foldstart - 1)
	table.insert(result, { "  ", nil })

	table.insert(result, { "      ...... 󰁂  " .. nline .. " lines folded", "Character" })
	return result
end

vim.opt.foldtext = "v:lua.custom_foldtext()"
