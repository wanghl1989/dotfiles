-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

vim.api.nvim_create_autocmd("VimLeave", {
  pattern = "*",
  command = "silent !zellij action switch-mode normal",
})

-- fcitx5
local fcitx5_remote = vim.fn.executable("fcitx5-remote") == 1

if fcitx5_remote then
  local M = {}
  local ZH_on = 2
  local EN_on = 1

  local sw_to_CH = "fcitx5-remote -o"
  local sw_to_EN = "fcitx5-remote -c"

  local stack_insert_status = 1 --save input status

  local function Get_fcitx_status() --get input status
    local cmd = io.popen("fcitx5-remote")
    local ret = cmd:read("*a")
    local tmp = tonumber(ret)
    cmd:close()
    return tmp
  end

  function M.Leave_insert()
    local exit_insert_status = Get_fcitx_status()
    stack_insert_status = exit_insert_status
    if exit_insert_status == ZH_on then
      os.execute(sw_to_EN)
    end
  end

  function M.Enter_insert()
    local enter_insert_status = EN_on
    if enter_insert_status ~= stack_insert_status then
      if stack_insert_status == ZH_on then
        os.execute(sw_to_CH)
      end
    else
      os.execute(sw_to_EN)
    end
  end

  local fcitx5_ime_group = vim.api.nvim_create_augroup("Fcitx5IME", {
    clear = true, -- 关键：创建前清空同名组，避免重复
  })

  vim.api.nvim_create_autocmd("InsertLeave", {
    group = fcitx5_ime_group,
    pattern = "*",
    callback = M.Leave_insert,
  })

  vim.api.nvim_create_autocmd("InsertEnter", {
    group = fcitx5_ime_group,
    pattern = "*",
    callback = M.Enter_insert,
  })
end
