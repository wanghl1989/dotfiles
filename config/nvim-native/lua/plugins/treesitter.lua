vim.pack.add({
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter" },
})

vim.api.nvim_create_autocmd("BufReadPre", {
	group = vim.api.nvim_create_augroup("SetupTreesitter", { clear = true }),
	once = true,
	callback = function()
		-- @diagnostic disable-next-line: missing-fields
		require("nvim-treesitter").setup({
			ensure_installed = {
				"diff",
				"python",
				"cpp",
				"c",
				"rust",
				"yaml",
			},
			ignore_install = {},
			auto_install = true,
			highlight = {
				enable = true,
				disable = { "latex" },
				additional_vim_regex_highlighting = {},
			},
			disable = function(lang, bufnr)
				return lang == "yaml" and vim.api.nvim_buf_line_count(bufnr) > 5000
			end,
			indent = { enable = true },
		})
	end,
})
