vim.pack.add({
    { src = "https://github.com/christoomey/vim-tmux-navigator" }, 
    { src = "https://github.com/mikesmithgh/kitty-scrollback.nvim"}
})

if vim.env.TMUX ~= nil and vim.env.TMUX ~= "" then
	vim.g.tmux_navigator_no_mappings = 1
	vim.keymap.set("n", "<C-h>", "<cmd>TmuxNavigateLeft<cr>")
	vim.keymap.set("n", "<C-j>", "<cmd>TmuxNavigateDown<cr>")
	vim.keymap.set("n", "<C-k>", "<cmd>TmuxNavigateUp<cr>")
	vim.keymap.set("n", "<C-l>", "<cmd>TmuxNavigateRight<cr>")
else
	vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Go to left window" })
	vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Go to lower window" })
	vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Go to upper window" })
	vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Go to right window" })
end



require("kitty-scrollback").setup()
