vim.pack.add({
	{ src = "https://github.com/folke/which-key.nvim" },
})

require("which-key").setup({})

vim.keymap.set({ "n", "x", "v", "x" }, "<leader>?", function()
	require("which-key").show({ global = false })
end, { desc = "Open which-key" })

local map_desc = function(mode, key, desc)
	vim.keymap.set(mode, key, "", { desc = desc })
end
map_desc("n", "<leader>g", " git")
map_desc("n", "<leader>f", "󰈞 find")
map_desc("n", "<leader>c", " code")
map_desc("n", "<leader>w", "save or close")
