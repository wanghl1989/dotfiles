vim.pack.add({
	{ src = "https://github.com/nvim-tree/nvim-web-devicons" },
	{ src = "https://github.com/nvim-lualine/lualine.nvim" },
})

-- vim.api.nvim_set_hl(0, "StatusLine", { bg = "NONE" })

require("lualine").setup({
	options = {
		icons_enabled = true,
		-- Selected theme with the existing transparent B/C sections.
		theme = require("plugins.theme"),
		disabled_filetypes = { statusline = { "dashboard", "alpha", "ministarter" } },
		-- component_separators = { left = "", right = "" },
		component_separators = { left = "|", right = "|" },
		section_separators = { left = "", right = "" },
		ignore_focus = {},
		always_divide_middle = true,
		always_show_tabline = true,
		globalstatus = vim.o.laststatus == 3,
		refresh = {
			statusline = 1000,
			tabline = 1000,
			winbar = 1000,
			refresh_time = 16, -- ~60fps
			events = {
				"WinEnter",
				"BufEnter",
				"BufWritePost",
				"SessionLoadPost",
				"FileChangedShellPost",
				"VimResized",
				"Filetype",
				"CursorMoved",
				"CursorMovedI",
				"ModeChanged",
			},
		},
	},
	sections = {
		lualine_a = { "mode" },
		lualine_b = {
			{ "branch", icon = "" },
			{
				"diff",
				symbols = { added = " ", modified = " ", removed = " " },
				source = function()
					local gitsigns = vim.b.gitsigns_status_dict
					if gitsigns then
						return {
							added = gitsigns.added,
							modified = gitsigns.changed,
							removed = gitsigns.removed,
						}
					end
				end,
			},
			{ "diagnostics" },
		},
		lualine_c = { require("utils.path").pretty_path() },
		lualine_x = {
			-- {
			-- 	function()
			-- 		return "  " .. require("dap").status()
			-- 	end,
			-- 	cond = function()
			-- 		return package.loaded["dap"] and require("dap").status() ~= ""
			-- 	end,
			-- 	color = function()
			-- 		return { fg = Snacks.util.color("Debug") }
			-- 	end,
			-- },
			{ "filetype", icon_only = true, separator = "", padding = { left = 1, right = 0 } },
			{
				function()
					local venv_path = require("venv-selector").venv()
					if not venv_path or venv_path == "" then
						return ""
					end
					local venv_name = vim.fn.fnamemodify(venv_path, ":t")
					return venv_name or ""
				end,
				icon = "",
				color = { fg = require("config.appearance").colors.error },
				cond = function()
					return package.loaded["venv-selector"] ~= nil
				end,
			},
		},
		lualine_y = {
			{ "progress", separator = " ", padding = { left = 1, right = 0 } },
		},
		lualine_z = {
			{
				"lsp_status",
				icon = false,
				-- Keep Z transparent and use the selected foreground color.
				color = { fg = require("config.appearance").colors.foreground, bg = "NONE", gui = "bold" },
				symbols = {
					spinner = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" },
					done = "✓",
					separator = " ",
				},
				ignore_lsp = {},
				show_name = true,
			},
		},
	},
	inactive_sections = {
		lualine_a = {},
		lualine_b = {},
		lualine_c = { "filename" },
		lualine_x = { "location" },
		lualine_y = {},
		lualine_z = {},
	},
	tabline = {},
	winbar = {},
	inactive_winbar = {},
	extensions = { "oil", "toggleterm", "mason" },
})
