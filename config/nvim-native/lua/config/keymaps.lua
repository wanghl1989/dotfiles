vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

local map = vim.keymap.set
local opts = { noremap = true, silent = true }

map("v", "<C-w>", "<NOP>", opts)
map("i", "<C-c>", "<ESC>", opts)
map("n", "<leader>nh", ":noh<CR>", { noremap = true, silent = true, desc = "Clear highlights" })
map("i", "jk", "<esc>", opts)

-- move
map({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true, silent = true })
map({ "n", "x" }, "<Down>", "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true, silent = true })
map({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true, silent = true })
map({ "n", "x" }, "<Up>", "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true, silent = true })

map("n", "<C-h>", "<C-w>h", { desc = "Go to Left Window", remap = true })
map("n", "<C-j>", "<C-w>j", { desc = "Go to Lower Window", remap = true })
map("n", "<C-k>", "<C-w>k", { desc = "Go to Upper Window", remap = true })
map("n", "<C-l>", "<C-w>l", { desc = "Go to Right Window", remap = true })

-- 调整窗口大小
map("n", "<C-Up>", ":resize +2<CR>", { desc = "Increase window height" })
map("n", "<C-Down>", ":resize -2<CR>", { desc = "Decrease window height" })
map("n", "<C-Left>", ":vertical resize -2<CR>", { desc = "Decrease window width" })
map("n", "<C-Right>", ":vertical resize +2<CR>", { desc = "Increase window width" })

map("n", "<A-j>", "<NOP>", opts)
map("n", "<A-k>", "<NOP>", opts)
map("i", "<A-j>", "<NOP>", opts)
map("i", "<A-k>", "<NOP>", opts)

map("v", "<A-j>", "<NOP>", opts)
map("v", "<A-k>", "<NOP>", opts)

map("v", "<C-w>", "<NOP>", opts)

-- split
map("n", "<leader>-", "<C-W>s", { desc = "Split Window Below", remap = true })
map("n", "<leader>|", "<C-W>v", { desc = "Split Window Right", remap = true })

-- safe file and quit
map("n", "<Leader>wc", "<C-W>w", { noremap = true, silent = true, desc = "Switch windows" })
map("n", "<Leader>ww", ":update<CR>", { noremap = true, desc = "Save windows" })
map("n", "<Leader>wq", ":bdelete<CR>", { noremap = true, desc = "Quit windows" })

map("n", "<Leader>qa", ":qa<CR>", { noremap = true, desc = "Quit all" })
map("n", "<Leader>qq", ":q<CR>", { noremap = true, desc = "Quit current" })

-- line operate
map("n", "gl", "$", opts)
map("n", "gh", "^", opts)

map("v", "gl", "$", opts)
map("v", "gh", "^", opts)

map("n", "dL", "d$", { noremap = true, silent = true, desc = "Delete to end of line" })
map("n", "dH", "d^", { noremap = true, silent = true, desc = "Delete to start of line" })

map("n", "cL", "c$", { noremap = true, silent = true, desc = "Change to end of line" })
map("n", "cH", "c^", { noremap = true, silent = true, desc = "Change to start of line" })

map("n", "yL", "y$", { noremap = true, silent = true, desc = "Yank to end of line" })
map("n", "yH", "y^", { noremap = true, silent = true, desc = "Change to start of line" })

map("n", "vL", "v$", { noremap = true, silent = true, desc = "Change to end of line" })
map("n", "vH", "v^", { noremap = true, silent = true, desc = "Change to start of line" })

map("v", "<leader>j", ":'<,'>join<CR>", { noremap = true, silent = true, desc = "Join the lines" })

map("v", "<leader><up>", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })
map("v", "<leader><down>", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })

map("v", "J", "<NOP>", opts)
map("v", "K", "<NOP>", opts)

map({ "i", "n", "x" }, "<A-u>", "<NOP>", opts)

-- mark
map("n", "<leader>ml", ":marks<cr>", { noremap = true, silent = true, desc = "Show all marks" })
map("n", "<leader>md", ":delmarks ", { noremap = true, silent = true, desc = "Delete mark" })
map("n", "<leader>ma", ":delmarks a-zA-Z0-9<CR>", { noremap = true, silent = true, desc = "Delete all marks" })

map("n", "<S-j>", function()
	vim.diagnostic.open_float()
end, opts)

map("v", "<", "<gv", { desc = "Indent code in visual mode" })
map("v", ">", ">gv", { desc = "Indent code in visual mode" })
