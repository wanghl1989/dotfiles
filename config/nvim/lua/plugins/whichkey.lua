vim.pack.add({
	{ src = "https://github.com/folke/which-key.nvim" },
})

require("which-key").setup({
	preset = "helix",
	spec = {
		{ mode = { "n", "x" },
			{ "<leader>b", group = "buffers" },
			{ "<leader>c", group = "code / LSP" },
			{ "<leader>f", group = "files / format" },
			{ "<leader>g", group = "git" },
			{ "<leader>h", group = "git hunks" },
			{ "<leader>m", group = "multicursor / marks" },
			{ "<leader>n", group = "notifications / highlights" },
			{ "<leader>q", group = "quit" },
			{ "<leader>s", group = "search" },
			{ "<leader>v", group = "surround" },
			{ "<leader>vf", group = "find surrounding" },
			{ "<leader>w", group = "windows / save" },
			{ "[", group = "previous" },
			{ "]", group = "next" },
			{ "g", group = "goto" },
			{ "z", group = "folds / view" },
		},
	},
})

-- Include both global mappings and mappings for the current buffer.
vim.keymap.set({ "n", "x" }, "<leader>?", function()
	require("which-key").show({ global = true })
end, { desc = "Show all available keymaps" })
