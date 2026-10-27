-- Cendre: https://github.com/Aejkatappaja/cendre
vim.pack.add({
    { src = "https://github.com/Aejkatappaja/cendre" },
})
vim.o.background = "dark"

-- Keep Neovim's embedded terminal on the selected terminal emulator palette.
local terminal_colors = {}
for i = 0, 15 do
    terminal_colors[i] = vim.g["terminal_color_" .. i]
end
require("cendre").setup({
    background = "hard", transparent = true,
    italic_comments = false, italic_virtual_text = false,
})
vim.cmd.colorscheme("cendre")
local c = require("cendre.palette").get("hard")
local colors = {
    background = c.bg0, surface = c.bg1, muted = c.comment,
    foreground = c.fg, accent = c.ember, error = c.error,
}
local selection = c.vis
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
    pattern = "cendre",
    callback = function() vim.schedule(apply_highlights) end,
})

local lualine_theme = vim.deepcopy(require("lualine.themes.cendre"))
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
