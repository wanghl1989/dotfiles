-- blink.cmp 安装补全配置以及触发加载
vim.pack.add({
	{ src = "https://github.com/saghen/blink.cmp", version = vim.version.range("1.*") },
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
			snippets = {
				preset = "default",
			},
			appearance = { nerd_font_variant = "normal" },
			keymap = {
				["<CR>"] = { "accept", "fallback" },
				["<Esc>"] = { "hide", "fallback" },
				["<C-j>"] = { "select_next", "fallback" },
				["<C-k>"] = { "select_prev", "fallback" },
				["<Tab>"] = { "select_and_accept" },
			},
			completion = {
				accept = {
					-- experimental auto-brackets support
					auto_brackets = {
						enabled = true,
					},
				},
				menu = {
					draw = {
						treesitter = { "lsp" },
					},
				},
				documentation = {
					auto_show = true,
					auto_show_delay_ms = 200,
				},

				list = { selection = { preselect = false, auto_insert = false } },
			},
			sources = {
				default = { "lsp", "path", "snippets", "buffer", "git", "dictionary", "calc" },
				providers = {
					buffer = {
						module = "blink.cmp.sources.buffer",
						score_offset = -3,
						opts = {
							get_bufnrs = function()
								return vim.tbl_filter(function(bufnr)
									return vim.bo[bufnr].buftype == ""
								end, vim.api.nvim_list_bufs())
							end,
						},
					},
					snippets = {
						module = "blink.cmp.sources.snippets",
						score_offset = -3,
						-- For `snippets.preset == 'luasnip'`
						opts = {
							use_show_condition = true,
							show_autosnippets = true,
							prefer_doc_trig = false,
							use_label_description = false,
						},
					},
					path = {
						module = "blink.cmp.sources.path",
						score_offset = 3,
						fallbacks = { "buffer" },
						opts = {
							trailing_slash = true,
							label_trailing_slash = true,
							get_cwd = function(context)
								return vim.fn.expand(("#%d:p:h"):format(context.bufnr))
							end,
							show_hidden_files_by_default = false,
							ignore_root_slash = false,
							max_entries = 500,
						},
					},
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
			cmdline = {
				enabled = true,
				keymap = {
					preset = "cmdline",
					["<Right>"] = false,
					["<Left>"] = false,
					["<Tab>"] = { "select_and_accept" },
				},
				completion = {
					list = { selection = { preselect = false } },
					menu = {
						auto_show = function(ctx)
							return vim.fn.getcmdtype() == ":"
						end,
					},
					ghost_text = { enabled = true },
				},
			},
		})
	end,
})
