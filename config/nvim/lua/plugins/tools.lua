vim.g.tmux_navigator_no_mappings = 1

vim.pack.add({
	{ src = "https://github.com/mikesmithgh/kitty-scrollback.nvim" },
	{ src = "https://github.com/christoomey/vim-tmux-navigator" },
	{ src = "https://github.com/bojackduy/nvim-herdr-navigation" },
})

if vim.env.HERDR_PANE_ID == nil and vim.env.TMUX ~= nil and vim.env.TMUX ~= "" then
	vim.keymap.set("n", "<C-h>", "<cmd>TmuxNavigateLeft<cr>", { desc = "Tmux Navigate Left" })
	vim.keymap.set("n", "<C-j>", "<cmd>TmuxNavigateDown<cr>", { desc = "Tmux Navigate Down" })
	vim.keymap.set("n", "<C-k>", "<cmd>TmuxNavigateUp<cr>", { desc = "Tmux Navigate Up" })
	vim.keymap.set("n", "<C-l>", "<cmd>TmuxNavigateRight<cr>", { desc = "Tmux Navigate Right" })
end

if vim.env.HERDR_PANE_ID ~= nil then
	-- The Neovim plugin lives in a subdirectory of the repository.
	local plugin = vim.pack.get({ "nvim-herdr-navigation" })[1]
	vim.opt.rtp:prepend(plugin.path .. "/nvim-herdr-navigation")
	vim.schedule(function()
		require("herdr-navigation").setup({
			keybindings = {
				left = "<C-h>",
				down = "<C-j>",
				up = "<C-k>",
				right = "<C-l>",
			},
		})
	end)
end

require("kitty-scrollback").setup()
