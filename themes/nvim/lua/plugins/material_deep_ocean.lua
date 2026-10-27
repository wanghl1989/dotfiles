vim.pack.add({
	{ src = "https://github.com/marko-cerovac/material.nvim" },
})

vim.g.material_style = "deep ocean"

require("material").setup({
	async_loading = false,
	disable = { background = true, term_colors = true },
	plugins = { "blink", "dashboard", "gitsigns", "mini", "noice", "which-key" },
	custom_highlights = {
		NoiceVirtualText = { fg = "#F78C6C" },
		Visual = { bg = "#1F2233" },
		["@attribute"] = { fg = "#89DDFF" },
		MiniPickMatchCurrent = { bg = "#1A1C25", bold = true },
		CursorLineNr = { bg = "#1A1C25", fg = "#EEFFFF", bold = true },
		CursorLine = { bg = "#1A1C25" },
		StatusLine = { fg = "#A6ACCD", bg = "NONE", reverse = false },
		StatusLineNC = { fg = "#717CB4", bg = "NONE", reverse = false },
		LspInlayHint = { bg = "#0F111A", fg = "#717CB4", italic = false },
		TreesitterContextLineNumber = { fg = "#F07178", bg = "NONE" },
	},
})

vim.cmd.colorscheme("material")

local colors = require("material.colors")
require("config.appearance").set({
	background = colors.editor.bg,
	surface = colors.editor.active,
	muted = colors.main.gray,
	foreground = colors.main.white,
	accent = colors.editor.accent,
	error = colors.main.red,
})

local diagnostic_colors = {
	Error = colors.main.red,
	Warn = colors.main.yellow,
	Info = colors.main.green,
	Hint = colors.main.cyan,
}

for kind, color in pairs(diagnostic_colors) do
	vim.api.nvim_set_hl(0, "Diagnostic" .. kind, { fg = color })
	vim.api.nvim_set_hl(0, "DiagnosticVirtualText" .. kind, {
		bg = colors.editor.bg,
		fg = color,
		italic = false,
	})
	vim.api.nvim_set_hl(0, "DiagnosticSign" .. kind, { fg = color })
	vim.api.nvim_set_hl(0, "DiagnosticUnderline" .. kind, { sp = color, undercurl = true })
end

local function disable_italics()
	for name, highlight in pairs(vim.api.nvim_get_hl(0, {})) do
		if highlight.italic then
			highlight.italic = false
			vim.api.nvim_set_hl(0, name, highlight)
		end
	end
end

disable_italics()
vim.api.nvim_create_autocmd("ColorScheme", {
	group = vim.api.nvim_create_augroup("DisableThemeItalics", { clear = true }),
	callback = function()
		vim.schedule(disable_italics)
	end,
})

-- Export the selected lualine theme, keeping B/C (and X/Y) transparent.
local lualine_theme = vim.deepcopy(require("lualine.themes.material"))
for _, mode in pairs(lualine_theme) do
	for _, section in ipairs({ "b", "c" }) do
		if mode[section] then
			mode[section].bg = "NONE"
		end
	end
end

return lualine_theme
