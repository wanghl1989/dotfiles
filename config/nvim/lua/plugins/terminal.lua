vim.pack.add({
	{ src = "https://github.com/akinsho/toggleterm.nvim" },
})

local height = math.floor(0.618 * vim.o.lines)
local width = math.floor(0.7 * vim.o.columns)
require("toggleterm").setup({
	open_mapping = [[<c-t>]],
	-- open_mapping = [[<leader>tl]],
	autochdir = true,
	shading_factor = "1",
	direction = "float",
	size = 20,
	float_opts = {
		width = width,
		height = height,
		border = "single",
	},
})

vim.api.nvim_create_autocmd("TermOpen", {
	pattern = "term://*toggleterm#*",
	callback = function()
		vim.keymap.set("t", "<esc>", [[<C-\><C-n>]], { buffer = 0 })
		vim.keymap.set("t", "<C-w>", [[<C-\><C-n><C-w>]], { buffer = 0 })
	end,
})
