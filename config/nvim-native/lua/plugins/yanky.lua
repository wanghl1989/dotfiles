vim.pack.add({
	{ src = "https://github.com/gbprod/yanky.nvim" },
})

require("yanky").setup({
	system_clipboard = {
		sync_with_ring = true,
		clipboard_register = nil,
	},
	highlight = {
		timer = 1000,
	},
})
