-- No personal plugins, swap, shada, or shell commands from buffer text.
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.writebackup = false
vim.opt.modeline = false
vim.opt.shadafile = "NONE"
vim.opt.number = false
vim.opt.relativenumber = false
vim.opt.wrap = false
vim.opt.cursorline = true
vim.opt.virtualedit = "block"
vim.opt.clipboard = ""
vim.opt.termguicolors = true
vim.opt.laststatus = 2
vim.opt.statusline = " COPY  h/j/k/l move · v/V/C-v select · y copy · q cancel %=%l/%L "
vim.api.nvim_set_hl(0, "Normal", { fg = "#839395", bg = "#001419" })
vim.api.nvim_set_hl(0, "Visual", { fg = "#adb7b7", bg = "#063540" })
vim.api.nvim_set_hl(0, "CursorLine", { bg = "#063540" })
vim.api.nvim_set_hl(0, "StatusLine", { fg = "#001419", bg = "#29a298" })
vim.api.nvim_create_autocmd("VimEnter", { once = true, callback = function()
  -- Delete the private capture once loaded; buffer remains in memory.
  local path = vim.api.nvim_buf_get_name(0)
  if vim.fn.fnamemodify(path, ":t"):match("^rex%-grab%.") then vim.fn.delete(path) end
  vim.bo.buftype = "nofile"
  vim.bo.bufhidden = "wipe"
  vim.bo.modifiable = false
  vim.cmd("normal! G$")
end })
vim.api.nvim_create_autocmd("TextYankPost", { callback = function()
  if vim.v.event.operator ~= "y" then return end
  local text = vim.fn.getreg(vim.v.event.regname)
  vim.fn.system({ "/usr/bin/pbcopy" }, text)
  if vim.v.shell_error ~= 0 then
    vim.notify("Clipboard copy failed; buffer kept open", vim.log.levels.ERROR)
    return
  end
  vim.schedule(function() vim.cmd("qa!") end)
end })
vim.keymap.set("n", "q", "<Cmd>qa!<CR>")
vim.keymap.set({"n", "x"}, "gh", "^")
vim.keymap.set({"n", "x"}, "gl", "$")
vim.keymap.set("x", "<CR>", "y")
