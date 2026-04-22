vim.pack.add({
	{ src = "https://github.com/scottmckendry/cyberdream.nvim" },
})

require("cyberdream").setup({
	transparent = true,
	saturation = 1,
	terminal_color = false,
	borderless_pickers = false,
	highlights = {
		Comment = { fg = "#898989", bg = "NONE", italic = true },
	},

	colors = {
		-- bg = "#181A26",
		fg = "#d2f8d2",
		dark = {
			-- bg_alt = "#1e2124",
			bg_highlight = "#3c5868",
			green = "#4fe88f",
			blue = "#7cf8f7",
			magenta = "#ff92df",
			cyan = "#5ea1ff",
			pink = "#FF79C6",
			purple = "#cba6f7",
			orange = "#ffbd5e",
		},
	},
})


vim.cmd("colorscheme cyberdream")
