
vim.pack.add({
	{ src = "https://github.com/windwp/nvim-ts-autotag" },
})

vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
	group = vim.api.nvim_create_augroup("SetupHtml", { clear = true }),
	pattern = { "*.html", "*.jsx", "*.tsx" },
	once = true,
	callback = function()
		require("nvim-ts-autotag").setup()
	end,
})
