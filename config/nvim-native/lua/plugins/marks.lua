vim.pack.add({
	{ src = "https://github.com/chentoast/marks.nvim" },
})

vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
	group = vim.api.nvim_create_augroup("SetupMarks", { clear = true }),
	once = true,
	callback = function()
        require("marks").setup()
    end
})



