vim.pack.add({
	{ src = "https://github.com/uhs-robert/oasis.nvim" },
})

-- Mirage supports light and dark backgrounds; always select the dark variant.
vim.o.background = "dark"
require("oasis").setup({
	style = "mirage",
	transparent = true,
	terminal_colors = false,
	styles = { italic = false },
})
vim.cmd.colorscheme("oasis-mirage")

local colors = require("oasis.color_palettes.oasis_mirage").dark
require("config.appearance").set({
	background = colors.bg.core,
	surface = colors.bg.mantle,
	muted = colors.fg.muted,
	foreground = colors.fg.core,
	accent = colors.theme.primary,
	error = colors.ui.diag.error.fg,
})

local overrides = {
	NoiceVirtualText = { fg = colors.theme.secondary },
	Visual = { bg = colors.bg.surface },
	MiniPickMatchCurrent = { bg = colors.bg.mantle, bold = true },
	CursorLine = { bg = colors.bg.mantle },
	CursorLineNr = { bg = colors.bg.mantle, fg = colors.fg.strong, bold = true },
	StatusLine = { fg = colors.fg.core, bg = "NONE", reverse = false },
	StatusLineNC = { fg = colors.fg.muted, bg = "NONE", reverse = false },
	LspInlayHint = { bg = colors.bg.core, fg = colors.fg.inlay, italic = false },
}
for name, highlight in pairs(overrides) do
	vim.api.nvim_set_hl(0, name, highlight)
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

local lualine_theme = vim.deepcopy(require("lualine.themes.oasis_mirage"))
for _, mode in pairs(lualine_theme) do
	for _, section in ipairs({ "b", "c" }) do
		if mode[section] then
			mode[section].bg = "NONE"
		end
	end
end
return lualine_theme
