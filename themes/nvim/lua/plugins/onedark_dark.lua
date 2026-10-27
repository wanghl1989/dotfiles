-- OneDark Dark: https://github.com/olimorris/onedarkpro.nvim
vim.pack.add({
    { src = "https://github.com/olimorris/onedarkpro.nvim" },
})
vim.o.background = "dark"

-- Keep Neovim's embedded terminal on the selected terminal emulator palette.
local terminal_colors = {}
for i = 0, 15 do
    terminal_colors[i] = vim.g["terminal_color_" .. i]
end
require("onedarkpro").setup({
    options = { transparency = true, terminal_colors = false, lualine_transparency = true },
})
vim.cmd.colorscheme("onedark_dark")
local c = require("onedarkpro.helpers").get_colors("onedark_dark")
local colors = {
    background = c.bg, surface = c.cursorline, muted = c.comment,
    foreground = c.fg, accent = c.blue, error = c.red,
}
local selection = c.selection
for i = 0, 15 do
    vim.g["terminal_color_" .. i] = terminal_colors[i]
end
require("config.appearance").set(colors)

local function apply_highlights()
    local overrides = {
        Normal = { fg = colors.foreground, bg = "NONE" },
        NormalNC = { fg = colors.foreground, bg = "NONE" },
        NormalFloat = { fg = colors.foreground, bg = "NONE" },
        SignColumn = { bg = "NONE" },
        FoldColumn = { bg = "NONE" },
        NoiceVirtualText = { fg = colors.accent },
        Visual = { bg = selection },
        MiniPickMatchCurrent = { bg = colors.surface, bold = true },
        CursorLine = { bg = colors.surface },
        CursorLineNr = { bg = colors.surface, fg = colors.foreground, bold = true },
        StatusLine = { fg = colors.foreground, bg = "NONE", reverse = false },
        StatusLineNC = { fg = colors.muted, bg = "NONE", reverse = false },
        LspInlayHint = { bg = colors.background, fg = colors.muted, italic = false },
    }
    for group, highlight in pairs(overrides) do
        vim.api.nvim_set_hl(0, group, highlight)
    end
    for group, highlight in pairs(vim.api.nvim_get_hl(0, {})) do
        if highlight.italic then
            highlight.italic = false
            vim.api.nvim_set_hl(0, group, highlight)
        end
    end
end
apply_highlights()
vim.api.nvim_create_autocmd("ColorScheme", {
    group = vim.api.nvim_create_augroup("SelectedThemeHighlights", { clear = true }),
    pattern = "onedark_dark",
    callback = function() vim.schedule(apply_highlights) end,
})

local lualine_theme = vim.deepcopy(require("lualine.themes.onedark_dark"))
-- Transparent B/C (and corresponding X/Y) need readable foregrounds.
for _, mode in pairs(lualine_theme) do
    for _, section in ipairs({ "b", "c" }) do
        if mode[section] then
            mode[section].bg = "NONE"
            mode[section].fg = colors.foreground
        end
    end
end
return lualine_theme
