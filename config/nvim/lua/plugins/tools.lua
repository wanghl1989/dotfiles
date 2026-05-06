vim.pack.add({
    "https://github.com/christoomey/vim-tmux-navigator",
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




vim.pack.add({
    "https://github.com/mikesmithgh/kitty-scrollback.nvim",
})


vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
	group = vim.api.nvim_create_augroup("SetupKitty", { clear = true }),
	once = true,
	callback = function()
        require("kitty-scrollback").setup()
    end
})
