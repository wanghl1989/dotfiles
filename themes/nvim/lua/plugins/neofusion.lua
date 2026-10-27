vim.pack.add({
	{ src = "https://github.com/diegoulloao/neofusion.nvim" },
})

local palette = require("neofusion.palette")

require("config.appearance").set({
	background = palette.dark0,
	surface = palette.dark2,
	muted = palette.gray,
	foreground = palette.light0,
	accent = palette.bright_aqua,
	error = palette.bright_red,
})

local overrides = {
	-- Keep the search counter readable without introducing a background.
	NoiceVirtualText = { fg = palette.light_red },
	Visual = { bg = palette.dark3 },
	["@attribute"] = { fg = palette.neutral_aqua },
	MiniPickMatchCurrent = {
		bg = palette.dark2,
		bold = true,
	},
	CursorLineNr = {
		bg = palette.dark2,
		fg = palette.light0,
		bold = true,
	},
	CursorLine = { bg = palette.dark2 },
	-- lualine owns the colored A section. Keep the base statusline transparent
	-- so its transparent B/C/X/Y sections do not inherit Neofusion's inverse bg.
	StatusLine = {
		fg = palette.light1,
		bg = "NONE",
		reverse = false,
	},
	StatusLineNC = {
		fg = palette.gray,
		bg = "NONE",
		reverse = false,
	},
	LspInlayHint = {
		bg = palette.dark1,
		fg = palette.gray,
		italic = false,
	},
	-- neofusion has a few legacy Markdown groups that hard-code italics.
	markdownItalic = { fg = palette.light3, italic = false },
	markdownBoldItalic = { fg = palette.light3, bold = true, italic = false },
	DashboardFooter = { fg = palette.neutral_purple, italic = false },
	["@markup.italic"] = { italic = false },
	["@text.emphasis"] = { italic = false },
}

local diagnostic_colors = {
	Error = palette.bright_red,
	Warn = palette.faded_yellow,
	Info = palette.bright_green,
	Hint = palette.neutral_aqua,
}

for kind, color in pairs(diagnostic_colors) do
	overrides["Diagnostic" .. kind] = { fg = color }
	overrides["DiagnosticVirtualText" .. kind] = {
		bg = palette.dark1,
		fg = color,
		italic = false,
	}
	overrides["DiagnosticSign" .. kind] = { fg = color }
	overrides["DiagnosticUnderline" .. kind] = {
		sp = color,
		undercurl = true,
	}
end

require("neofusion").setup({
	terminal_colors = false,
	undercurl = true,
	underline = true,
	bold = true,
	italic = {
		strings = false,
		emphasis = false,
		comments = false,
		operators = false,
		folds = false,
	},
	strikethrough = true,
	transparent_mode = true,
	dim_inactive = false,
	overrides = overrides,
})

vim.cmd.colorscheme("neofusion")

local function disable_italics()
	for name, highlight in pairs(vim.api.nvim_get_hl(0, {})) do
		if highlight.italic then
			highlight.italic = false
			vim.api.nvim_set_hl(0, name, highlight)
		end
	end
end

-- Also cover legacy syntax groups (for example htmlItalic) that are not
-- controlled by the colorscheme's italic options.
disable_italics()
vim.api.nvim_create_autocmd("ColorScheme", {
	group = vim.api.nvim_create_augroup("DisableThemeItalics", { clear = true }),
	callback = function()
		vim.schedule(disable_italics)
	end,
})

-- Export the selected lualine theme, keeping B/C (and X/Y) transparent.
local lualine_theme = vim.deepcopy(require("neofusion.lualine"))
for _, mode in pairs(lualine_theme) do
	for _, section in ipairs({ "b", "c" }) do
		if mode[section] then
			mode[section].bg = "NONE"
		end
	end
end

return lualine_theme
