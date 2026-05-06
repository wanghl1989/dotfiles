vim.pack.add({
	{ src = "https://github.com/f4z3r/gruvbox-material.nvim" },
})

require("gruvbox-material").setup({
	italics = false, -- enable italics in general
	contrast = "hard", -- set contrast, can be any of "hard", "medium", "soft"
	comments = {
		italics = false, -- enable italic comments
	},
	background = {
		transparent = true, -- set the background to be opaque
	},
	float = {
		force_background = false, -- set to true to force backgrounds on floats even when
		background_color = nil, -- set color for float backgrounds. If nil, uses the default color set
	},
	signs = {
		force_background = false, -- set to true to force backgrounds on signs even when
		background_color = nil, -- set color for sign backgrounds. If nil, uses the default color set
	},
	customize = nil
})

local colors = require("gruvbox-material.colors").get(vim.o.background, "hard")

vim.api.nvim_set_hl(0, "MyCustomGroup", {
	fg = colors.fg0,
	bg = colors.bg1,
	bold = true,
})

vim.cmd("colorscheme gruvbox-material")
