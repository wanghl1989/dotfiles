-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- #map("n", "<esc>k", "", { noremap = true, silent = true })
-- #map("n", "<esc>j", "", { noremap = true, silent = true })

map("n", "<leader>n", "<NOP>", { desc = "notification and highlights" })
map("n", "<A-j>", "<NOP>", opts)
map("n", "<A-k>", "<NOP>", opts)
map("i", "<A-j>", "<NOP>", opts)
map("i", "<A-k>", "<NOP>", opts)

map("v", "<A-j>", "<NOP>", opts)
map("v", "<A-k>", "<NOP>", opts)



-- common set
map("n", "<leader>nh", ":noh<CR>", { noremap = true, silent = true, desc = "Clear highlights" })
map("v", "<C-w>", "<NOP>", opts)
map("i", "<C-c>", "<ESC>", opts)
map("i", "jk", "<esc>", opts)

-- safe file and quit
map("n", "<Leader>wc", "<C-W>w", { noremap = true, silent = true, desc = "Switch windows" })
map("n", "<Leader>ww", ":update<CR>", { noremap = true, desc = "Save windows" })
map("n", "<leader>wq", function()
  Snacks.bufdelete()
end, { desc = "Delete Buffer", noremap = true })
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

map("v", "<leader>j", ":'<,'>join<CR>", { noremap = true, silent = true, desc = "Join the lines"})

map("v", "<leader><up>", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })
map("v", "<leader><down>", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })

map("v", "J", "<NOP>", opts)
map("v", "K", "<NOP>", opts)

map({ "i", "n", "x" }, "<A-u>", "<NOP>", opts)


map("n", "<S-j>", function()
  vim.diagnostic.open_float()
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

-- Oil

local oil = require("oil")
map("n", "<leader>e", function()
  if vim.bo.filetype == "oil" then
    Snacks.bufdelete()
  else
    oil.open()
  end
end, { noremap = true, desc = "Toggle Oil File Explorer" })

map("n", "<leader>E", function()
  if vim.bo.filetype == "oil" then
    Snacks.bufdelete()
  else
    oil.open(vim.fn.getcwd())
  end
end, { noremap = true, desc = "Toggle Oil File Explorer(Root)" })
