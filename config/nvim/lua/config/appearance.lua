-- The selected plugins/theme.lua provides colors for shared UI components.
local M = {}

function M.set(colors, lualine)
	M.colors = colors
	M.lualine = lualine
end

return M
