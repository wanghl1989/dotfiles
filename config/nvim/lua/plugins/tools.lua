vim.pack.add({
    { src = "https://github.com/christoomey/vim-tmux-navigator" }, 
    { src = "https://github.com/mikesmithgh/kitty-scrollback.nvim"}
})

if vim.env.TMUX ~= nil and vim.env.TMUX ~= "" then
	vim.g.tmux_navigator_no_mappings = 1
	vim.keymap.set("n", "<C-h>", "<cmd>TmuxNavigateLeft<cr>", { desc = "Tmux Navigate Left" })
	vim.keymap.set("n", "<C-j>", "<cmd>TmuxNavigateDown<cr>", { desc = "Tmux Navigate Down" })
	vim.keymap.set("n", "<C-k>", "<cmd>TmuxNavigateUp<cr>", { desc = "Tmux Navigate Up" })
	vim.keymap.set("n", "<C-l>", "<cmd>TmuxNavigateRight<cr>", { desc = "Tmux Navigate Right" })
end



require("kitty-scrollback").setup()
