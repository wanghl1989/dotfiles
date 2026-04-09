vim.pack.add({
	{ src = "https://github.com/nvim-mini/mini.ai" },
	{ src = "https://github.com/nvim-mini/mini.icons" },
	{ src = "https://github.com/nvim-mini/mini.surround" },
})

-- Mini
require("mini.ai").setup({
	mappings = {
		goto_left = "[",
		got_right = "]",
	},
})
require("mini.icons").setup({
	style = "glyph",
	file = {
		README = { glyph = "󰆈", hl = "MiniIconsYellow" },
		["README.md"] = { glyph = "󰆈", hl = "MiniIconsYellow" },
	},
	filetype = {
		bash = { glyph = "󱆃", hl = "MiniIconsGreen" },
		sh = { glyph = "󱆃", hl = "MiniIconsGrey" },
		toml = { glyph = "󱄽", hl = "MiniIconsOrange" },
	},
})
require("mini.surround").setup({
	mappings = {
		add = "<leader>va", -- Add surrounding in Normal and Visual modes
		delete = "<leader>vd", -- Delete surrounding
		find = "<leader>vfr", -- Find surrounding (to the right)
		find_left = "<leader>vfl", -- Find surrounding (to the left)
		highlight = "<leader>vs", -- Highlight surrounding
		replace = "<leader>vr", -- Replace surrounding
		update_n_lines = "<leader>vn", -- Update `n_lines`
	},
})
