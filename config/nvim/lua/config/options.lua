-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
local opt = vim.opt
vim.g.lazyvim_python_lsp = "basedpyright"
vim.g.lazyvim_python_ruff = "ruff"
-- 自动format
vim.g.autoformat = false

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

local root_patterns = {
  -- directories
  "client",
  "server",

  -- version control systems
  "_darcs",
  ".hg",
  ".bzr",
  ".svn",
  ".git",

  -- build tools
  "Makefile",
  "CMakeLists.txt",
  "build.gradle",
  "build.gradle.kts",
  "pom.xml",
  "build.xml",

  -- node.js and javascript
  "package.json",
  "package-lock.json",
  "yarn.lock",
  ".nvmrc",
  "gulpfile.js",
  "Gruntfile.js",

  -- python
  "requirements.txt",
  "Pipfile",
  "pyproject.toml",
  "setup.py",
  "tox.ini",

  -- rust
  "Cargo.toml",

  -- go
  "go.mod",

  -- elixir
  "mix.exs",

  -- configuration files
  ".prettierrc",
  ".prettierrc.json",
  ".prettierrc.yaml",
  ".prettierrc.yml",
  ".eslintrc",
  ".eslintrc.json",
  ".eslintrc.js",
  ".eslintrc.cjs",
  ".eslintignore",
  ".stylelintrc",
  ".stylelintrc.json",
  ".stylelintrc.yaml",
  ".stylelintrc.yml",
  ".editorconfig",
  ".gitignore",

  -- html projects
  "index.html",

  -- miscellaneous
  "README.md",
  "README.rst",
  "LICENSE",
  "Vagrantfile",
  "Procfile",
  ".env",
  ".env.example",
  "config.yaml",
  "config.yml",
  ".terraform",
  "terraform.tfstate",
  ".kitchen.yml",
  "Berksfile",
}

vim.g.root_spec = { "cwd" }
