-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- #map("n", "<esc>k", "", { noremap = true, silent = true })
-- #map("n", "<esc>j", "", { noremap = true, silent = true })

map("n", "<leader>n", "", { desc = "notification and highlights" })
map("n", "<A-j>", "", { desc = "" })
map("n", "<A-k>", "", { desc = "" })
map("i", "<A-j>", "", { desc = "" })
map("i", "<A-k>", "", { desc = "" })

map("v", "<A-j>", "", { desc = "Move Down" })
map("v", "<A-k>", "", { desc = "Move Up" })
-- safe file and quit
map("n", "<Leader>ww", ":update<CR>", { noremap = true, desc = "Save windows" })
map("n", "<Leader>wc", "<C-W>w", { noremap = true, silent = true, desc = "Switch windows" })
map("n", "<leader>wq", function()
  Snacks.bufdelete()
end, { desc = "Delete Buffer", noremap = true })

map("n", "<Leader>Q", ":qa<Return>", opts)

map("n", "gl", "$", opts)
map("n", "gh", "^", opts)

map("v", "gl", "$", opts)
map("v", "gh", "^", opts)

map("n", "<S-j>", "", opts)

map("n", "<leader>nh", ":noh<CR>", { noremap = true, silent = true, desc = "Clear highlights" })

map("i", "jk", "<esc>", opts)

map({ "i", "n", "x" }, "<A-u>", "", opts)

map("v", "<leader>j", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
map("v", "<leader>k", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

-- mark
map("n", "<leader>ml", ":marks<cr>", { noremap = true, silent = true, desc = "Show all marks" })
map("n", "<leader>md", ":delmarks ", { noremap = true, silent = true, desc = "Delete mark" })
map("n", "<leader>ma", ":delmarks a-zA-Z0-9<CR>", { noremap = true, silent = true, desc = "Delete all marks" })

map("n", "<S-j>", function()
  vim.diagnostic.oepn_float()
end, opts)

map("n", "<leader>fh", function()
  Snacks.picker.help()
end, { noremap = true, silent = true, desc = "Show help." })

map("n", "<leader>fs", function()
  local bufnr = vim.api.nvim_get_current_buf()
  local clients = vim.lsp.get_clients({ bufnr = bufnr })

  local function has_lsp_symbols()
    for _, client in ipairs(clients) do
      if client.server_capabilities.documentSymbolProvider then
        return true
      end
    end
    return false
  end

  if has_lsp_symbols() then
    Snacks.picker.lsp_symbols({
      layout = "dropdown",
      tree = true,
      -- on_show = function()
      --   vim.cmd.stopinsert()
      -- end,
    })
  else
    Snacks.picker.treesitter()
  end
end, { desc = "Find symbol in current buffer" })

map({ "n", "v" }, "<leader>yy", [["+y]], { noremap = true, desc = "Copy to clipboard" })
map({ "n", "v" }, "<leader>yl", [["+Y]], { noremap = true, desc = "Copy lines to clipboard" })
