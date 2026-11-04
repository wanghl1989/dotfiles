require("keys")
require("grab")
local data = os.getenv('XDG_DATA_HOME') or (os.getenv('HOME') .. '/.local/share')
-- Match Neovim's vim.pack installation path; load after keys.lua to override navigation.
local plugin = data .. '/nvim/site/pack/core/opt/rex-navigator.nvim'
local ok, err = pcall(function()
  dofile(plugin .. '/rex/navigator.lua').setup()
end)
if not ok then
  rex.log('warn', 'rex-navigator not loaded: ' .. tostring(err))
end
