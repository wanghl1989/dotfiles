vim.pack.add({
	{ src = "https://github.com/craftzdog/solarized-osaka.nvim" },
})

vim.o.background = "dark"
require("solarized-osaka").setup({
	style = "",
	transparent = true,
	terminal_colors = false,
	styles = {
		comments = { italic = false },
		keywords = { italic = false },
		sidebars = "transparent",
		floats = "transparent",
	},
	on_highlights = function(hl, c)
		hl.NoiceVirtualText = { fg = c.orange }
		hl.Visual = { bg = c.base02 }
		hl.MiniPickMatchCurrent = { bg = c.bg_highlight, bold = true }
		hl.CursorLine = { bg = c.bg_highlight }
		hl.CursorLineNr = { bg = c.bg_highlight, fg = c.base1, bold = true }
		hl.StatusLine = { fg = c.fg, bg = "NONE", reverse = false }
		hl.StatusLineNC = { fg = c.base01, bg = "NONE", reverse = false }
		hl.LspInlayHint = { bg = c.bg, fg = c.base01, italic = false }
	end,
})
vim.cmd.colorscheme("solarized-osaka")

local colors = require("solarized-osaka.colors").setup()
require("config.appearance").set({
	background = colors.bg,
	surface = colors.bg_highlight,
	muted = colors.base01,
	foreground = colors.fg,
	accent = colors.cyan,
	error = colors.error,
})

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

local lualine_theme = vim.deepcopy(require("lualine.themes.solarized-osaka"))
for _, mode in pairs(lualine_theme) do
	for _, section in ipairs({ "b", "c" }) do
		if mode[section] then
			mode[section].bg = "NONE"
			-- Upstream B uses dark text on a light background. Transparent
			-- B/C (also used by X/Y) need light text on the terminal background.
			mode[section].fg = colors.fg
		end
	end
end
return lualine_theme
