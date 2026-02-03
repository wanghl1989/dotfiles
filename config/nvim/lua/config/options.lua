-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
local opt = vim.opt
vim.g.lazyvim_python_lsp = "basedpyright"
vim.g.root_spec = { "cwd" }
vim.o.jumpoptions = "stack"
-- opt.wrap = true
opt.swapfile = false
opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 2
opt.smartindent = true
opt.termguicolors = true
opt.swapfile = false
opt.mouse = "a"
opt.laststatus = 3
opt.winborder = "rounded"

-- 禁止自动注释续行
opt.formatoptions:remove({ "c", "r", "o" })
vim.api.nvim_create_autocmd("FileType", {
  pattern = "*",
  callback = function()
    vim.opt.formatoptions:remove({ "c", "r", "o" })
  end,
})
-- 使得左右键可以跨行
-- vim.o.whichwrap = vim.o.whichwrap .. "<>,h,l"
