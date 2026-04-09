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
opt.smartindent = true
opt.termguicolors = true
opt.swapfile = false
opt.mouse = "a"
opt.laststatus = 3
opt.winborder = "rounded"
-- opt.cursorcolumn = true

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

-- this file is for indent settings

local indent_configs = {
    -- 2 空格缩进组
    {
        size = 2,
        expand = true,
        fts = { "json", "jsonc", "yaml", "markdown", "sh", "toml", "sql", "gitcommit" },
    },
    -- 4 空格缩进组
    {
        size = 4,
        expand = true,
        fts = { "c", "cpp", "python", "lua", "rust" },
    },
    -- 4 物理 Tab 组
    {
        size = 4,
        expand = false,
        fts = { "go" },
    },
}
-- 全局默认值
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

local indent_group = vim.api.nvim_create_augroup("User_LanguagesIndent", { clear = true })
for _, config in ipairs(indent_configs) do
    vim.api.nvim_create_autocmd("FileType", {
        pattern = config.fts, -- Neovim 的 pattern 原生支持直接传入 table: { 'json', 'yaml' }
        group = indent_group,
        callback = function()
            vim.opt_local.tabstop = config.size
            vim.opt_local.shiftwidth = config.size
            vim.opt_local.softtabstop = config.size
            vim.opt_local.expandtab = config.expand
        end,
    })
end


vim.g.root_spec = { "cwd" }



-- folding
vim.o.foldcolumn = "0"
vim.o.foldlevel = 99
vim.o.foldlevelstart = 99
vim.o.foldenable = false
vim.o.foldmethod = "expr"
vim.o.fillchars = "eob: ,fold: ,foldopen:,foldsep: ,foldclose:"
vim.o.foldexpr = "v:lua.vim.treesitter.foldexpr()"

local function fold_virt_text(result, start_text, lnum)
    local text = ""
    local hl
    for i = 1, #start_text do
        local char = start_text:sub(i, i)
        local new_hl = "@text"

        -- if semantic tokens unavailable, use treesitter hl
        local sem_tokens = vim.lsp.semantic_tokens.get_at_pos(0, lnum, i)
        if sem_tokens and #sem_tokens > 0 then
            new_hl = "@" .. sem_tokens[1].type
        else
            local captures = vim.treesitter.get_captures_at_pos(0, lnum, i - 1)
            if #captures > 0 then
                local top = captures[1]
                local top_priority = (top.metadata and tonumber(top.metadata.priority)) or 0
                for _, cap in ipairs(captures) do
                    local raw_prio = cap.metadata and cap.metadata.priority
                    local prio = tonumber(raw_prio) or 0
                    if prio > top_priority then
                        top = cap
                        top_priority = prio
                    end
                end
                new_hl = "@" .. top.capture
            end
        end

        if new_hl then
            if new_hl ~= hl then
                table.insert(result, { text, hl })
                text = ""
                hl = nil
            end
            text = text .. char
            hl = new_hl
        else
            text = text .. char
        end
    end
    table.insert(result, { text, hl })
end
function _G.custom_foldtext()
    local start_text = vim.fn.getline(vim.v.foldstart):gsub("\t", string.rep(" ", vim.o.tabstop))
    local nline = vim.v.foldend - vim.v.foldstart
    local result = {}
    fold_virt_text(result, start_text, vim.v.foldstart - 1)
    table.insert(result, { "  ", nil })

    table.insert(result, { "      ...... 󰁂  " .. nline .. " lines folded", "Character" })
    return result
end

vim.opt.foldtext = "v:lua.custom_foldtext()"
