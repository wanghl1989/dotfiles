vim.pack.add({
	{ src = "https://github.com/marko-cerovac/material.nvim" },
})

-- require("gruvbox-material").setup({
-- 	italics = false, -- enable italics in general
-- 	contrast = "hard", -- set contrast, can be any of "hard", "medium", "soft"
-- 	comments = {
-- 		italics = false, -- enable italic comments
-- 	},
-- 	background = {
-- 		transparent = true, -- set the background to be opaque
-- 	},
-- 	float = {
-- 		force_background = false, -- set to true to force backgrounds on floats even when
-- 		background_color = nil, -- set color for float backgrounds. If nil, uses the default color set
-- 	},
-- 	signs = {
-- 		force_background = false, -- set to true to force backgrounds on signs even when
-- 		background_color = nil, -- set color for sign backgrounds. If nil, uses the default color set
-- 	},
-- 	customize = nil,
-- })

require("material").setup({

	contrast = {
		terminal = true, -- Enable contrast for the built-in terminal
		sidebars = false, -- Enable contrast for sidebar-like windows ( for example Nvim-Tree )
		floating_windows = true, -- Enable contrast for floating windows
		cursor_line = true, -- Enable darker background for the cursor line
		lsp_virtual_text = true, -- Enable contrasted background for lsp virtual text
		non_current_windows = true, -- Enable contrasted background for non-current windows
		filetypes = {}, -- Specify which filetypes get the contrasted (darker) background
	},

	styles = { -- Give comments style such as bold, italic, underline etc.
		comments = { italic = false },
		strings = {
			italic = false --[[ bold = true ]],
		},
		keywords = {
			italic = false --[[ underline = true ]],
		},
		functions = {
			italic = false --[[ bold = true, undercurl = true ]],
		},
		variables = {},
		operators = {},
		types = {},
	},

	plugins = { -- Uncomment the plugins that you use to highlight them
		-- Available plugins:
		"blink",
		-- "coc",
		-- "colorful-winsep",
		-- "dap",
		-- "dashboard",
		-- "eyeliner",
		-- "fidget",
		"flash",
		"gitsigns",
		-- "harpoon",
		-- "hop",
		-- "illuminate",
		-- "indent-blankline",
		-- "lspsaga",
		"mini",
		-- "neo-tree",
		-- "neogit",
		-- "neorg",
		-- "neotest",
		"noice",
		"nvim-cmp",
		-- "nvim-navic",
		-- "nvim-notify",
		-- "nvim-tree",
		"nvim-web-devicons",
		-- "rainbow-delimiters",
		-- "sneak",
		-- "telescope",
		-- "trouble",
		"which-key",
	},

	disable = {
		colored_cursor = false, -- Disable the colored cursor
		borders = false, -- Disable borders between vertically split windows
		background = true, -- Prevent the theme from setting the background (NeoVim then uses your terminal background)
		term_colors = false, -- Prevent the theme from setting terminal colors
		eob_lines = false, -- Hide the end-of-buffer lines
	},

	high_visibility = {
		lighter = true, -- Enable higher contrast text for lighter style
		darker = false, -- Enable higher contrast text for darker style
	},

	lualine_style = "default", -- Lualine style ( can be 'stealth' or 'default' )

	async_loading = true, -- Load parts of the theme asynchronously for faster startup (turned on by default)

	custom_colors = nil, -- If you want to override the default colors, set this to a function

	-- Keep overrides here so they are applied after material.nvim finishes its
	-- asynchronous highlight loading.
	custom_highlights = function(colors)
		local highlights = {
			Visual = { bg = "#332687"},
			-- material.nvim links attributes to DiffChange, which gives Python
			-- decorators such as @dataclass an unrelated diff background.
			["@attribute"] = { fg = colors.main.cyan },
			MiniPickMatchCurrent = {
				bg = "#232637",
				fg = colors.editor.bg,
				bold = true,
			},
			CursorLineNr = {
				bg = "#232637",
				fg = colors.editor.accent,
				bold = true,
			},
			CursorLine = {
				bg = "#232637",
			         },
			LspInlayHint = {
				bg = colors.editor.active,
				fg = colors.editor.fg_dark,
				italic = false,
			},
		}

		local diagnostic_colors = {
			Error = colors.lsp.error,
			Warn = colors.lsp.warning,
			Info = colors.lsp.info,
			Hint = colors.lsp.hint,
		}

		for kind, color in pairs(diagnostic_colors) do
			highlights["Diagnostic" .. kind] = { fg = color }
			highlights["DiagnosticVirtualText" .. kind] = {
				bg = colors.editor.active,
				fg = color,
				italic = false,
			}
			highlights["DiagnosticSign" .. kind] = { fg = color }
			highlights["DiagnosticUnderline" .. kind] = {
				sp = color,
				undercurl = true,
			}
		end

		return highlights
	end,
})

vim.g.material_style = "deep ocean"
vim.cmd("colorscheme material")
