vim.g.tmux_navigator_no_mappings = 1

vim.pack.add({
	{ src = "https://github.com/mikesmithgh/kitty-scrollback.nvim" },
	{ src = "https://github.com/christoomey/vim-tmux-navigator" },
	{ src = "https://github.com/bojackduy/nvim-herdr-navigation" },
    { src = 'https://github.com/baggiponte/rex-navigator.nvim' }
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

require('rex-navigator').setup({
  mappings = true, -- install Ctrl-h/j/k/l in normal mode
  terminal = true, -- also install terminal-mode navigation
  wrap = true,     -- wrap around Rex panes at the outer layout edge
  -- rex_cmd = '/absolute/path/to/rex', -- override automatic CLI discovery
})
require("kitty-scrollback").setup()
