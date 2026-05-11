vim.pack.add({
	{ src = "https://github.com/imsnif/kdl.vim" },
})

vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
	group = vim.api.nvim_create_augroup("SetupRust", { clear = true }),
	pattern = { "*.rs", "*.kdl" },
    once = true,
	callback = function()
	end,
})
