vim.pack.add({
	{ src = "https://github.com/folke/which-key.nvim" },
})

require("which-key").setup({
	preset = "helix",
	defaults = {},
	spec = {
		{
			mode = { "n", "x" },
			-- { "<leader><tab>", group = "tabs" },
			{ "<leader>c", group = " code" },
			-- { "<leader>d", group = "debug" },
			-- { "<leader>dp", group = "profiler" },
			{ "<leader>f", group = "󰈞 file/find" },
			{ "<leader>g", group = " git" },
			{ "<leader>q", group = "quit/session" },
			{ "<leader>s", group = "󰈞 search" },
			-- { "<leader>u", group = "ui" },
			-- { "<leader>x", group = "diagnostics/quickfix" },
			{ "[", group = "prev" },
			{ "]", group = "next" },
			{ "g", group = "goto" },
			{ "<leader>v", group = "surround" },
			{ "<leader>m", group = "multicusor" },
			{ "z", group = "fold" },
			{
				"<leader>b",
				group = "buffer",
				expand = function()
					return require("which-key.extras").expand.buf()
				end,
			},
			{
				"<leader>w",
				group = "save/quit",
			},
		},
	},
})

vim.keymap.set({ "n", "x", "v" }, "<leader>?", function()
	require("which-key").show({ global = false })
end, { desc = "Open which-key" })
