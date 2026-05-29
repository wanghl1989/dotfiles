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
	customize = nil,
})


local function set_custom_highlights()

    local theme_colors = require("gruvbox-material.colors").get(vim.o.background, "hard")
	-- Inlay 提示
	vim.api.nvim_set_hl(0, "LspInlayHint", { fg = "#727364", bg = "NONE", italic = false })

	-- 诊断配色统一配置
	local colors = {
		Error = "#9a3922",
		Warn = "#976a2e",
		Info = "#5d6e63",
		Hint = "#395725",
	}

	for type, color in pairs(colors) do
		-- 代码旁的虚拟文本
		vim.api.nvim_set_hl(0, "DiagnosticVirtualText" .. type, { fg = color, italic = false })
		-- 左侧边栏符号
		vim.api.nvim_set_hl(0, "DiagnosticSign" .. type, { fg = color })
		-- 代码下划线（波浪线）
		vim.api.nvim_set_hl(0, "DiagnosticUnderline" .. type, { undercurl = true, sp = color })
	end
    vim.api.nvim_set_hl(0, "CursorLineNr", {
        bg = theme_colors.bg,
        fg = theme_colors.green
    })
    vim.api.nvim_set_hl(0, "Visual", {
        bg = "#5d6e63",  -- 背景色（十六进制）
    })
end

vim.api.nvim_create_autocmd("ColorScheme", { callback = set_custom_highlights })

vim.cmd("colorscheme gruvbox-material")
