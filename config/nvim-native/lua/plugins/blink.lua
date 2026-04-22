-- blink.cmp 安装补全配置以及触发加载
vim.pack.add({
	{ src = "https://github.com/saghen/blink.cmp",                version = vim.version.range("1.*") },
	{ src = "https://github.com/nvim-lua/plenary.nvim" },
	{ src = "https://github.com/Kaiser-Yang/blink-cmp-git" },
	{ src = "https://github.com/Kaiser-Yang/blink-cmp-dictionary" },
	{ src = "https://github.com/joelazar/blink-calc" },
})

vim.api.nvim_create_autocmd({ "InsertEnter", "CmdlineEnter", "LspAttach" }, {
	pattern = "*",
	group = vim.api.nvim_create_augroup("SetupBlink", { clear = true }),
	once = true,
	callback = function()
		require("blink.cmp").setup({
			keymap = {
				["<CR>"] = { "accept", "fallback" },
				["<Esc>"] = { "hide", "fallback" },
				["<C-j>"] = { "select_next", "fallback" },
				["<C-k>"] = { "select_prev", "fallback" },
				["<Tab>"] = { "select_and_accept" },
			},
			completion = {
				list = { selection = { preselect = false, auto_insert = false } },
			},
			sources = {
				default = { "git", "dictionary", "calc" },
				providers = {
					calc = {
						name = "Calc",
						module = "blink-calc",
					},
					git = {
						module = "blink-cmp-git",
						name = "Git",
						opts = {},
					},
					dictionary = {
						module = "blink-cmp-dictionary",
						name = "Dict",
						min_keyword_length = 3,
						max_items = 10,
						opts = {
							dictionary_files = { vim.fn.expand("~/.config/dict/words.txt") },
						},
					},
				},
			},
		})
	end
})
