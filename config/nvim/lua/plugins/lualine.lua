-- -- Lualine word count extension
-- -- Shows word count in the status line for text files
-- return {
--   "nvim-lualine/lualine.nvim",
--   event = "VeryLazy",
--   opts = function(_, opts)
--     local function is_textfile()
--       local filetype = vim.bo.filetype
--       return filetype == "markdown"
--         or filetype == "asciidoc"
--         or filetype == "pandoc"
--         or filetype == "tex"
--         or filetype == "text"
--     end
--
--     local function wordcount()
--       local wc = vim.fn.wordcount()
--       local visual_words = wc.visual_words or wc.words
--       local word_string = visual_words == 1 and " word" or " words"
--       return tostring(visual_words) .. word_string
--     end
--
--     -- local function is_pythonfile()
--     --   local filetype = vim.bo.filetype
--     --   return filetype == "py" or filetype == "pyi" or filetype == "pyw"
--     -- end
--     --
--     -- local function venvSelect()
--     --   local venv_path = require("venv-selector").venv()
--     --   if not venv_path or venv_path == "" then
--     --     return ""
--     --   end
--     --
--     --   local venv_name = vim.fn.fnamemodify(venv_path, ":t")
--     --   if not venv_name then
--     --     return ""
--     --   end
--     --
--     --   local output = "🐍 " .. venv_name .. " " -- Changes only the icon but you can change colors or use powerline symbols here.
--     --   return output
--     -- end
--     opts.component_separators = { left = "", right = "" }
--     opts.section_separators = { left = "", right = "" }
--
--     table.insert(opts.sections.lualine_z, { wordcount, cond = is_textfile })
--     table.insert(opts.sections.lualine_x, { "venv-selector", icon = "\u{e606}", color = { fg = "#50f872" } })
--
--     -- Update the pretty_path component to not truncate filenames
--     -- Replace the existing pretty_path component in lualine_c
--     opts.sections.lualine_c[4] = { LazyVim.lualine.pretty_path({ length = 0 }) }
--   end,
-- }
return {
  "nvim-lualine/lualine.nvim",
  event = "VeryLazy",
  init = function()
    vim.g.lualine_laststatus = vim.o.laststatus
    if vim.fn.argc(-1) > 0 then
      -- set an empty statusline till lualine loads
      vim.o.statusline = " "
    else
      -- hide the statusline on the starter page
      vim.o.laststatus = 0
    end
  end,
  opts = function()
    local lualine_require = require("lualine_require")
    lualine_require.require = require

    local icons = LazyVim.config.icons

    vim.o.laststatus = vim.g.lualine_laststatus

    local opts = {
      options = {
        theme = "auto",
        globalstatus = vim.o.laststatus == 3,
        disabled_filetypes = { statusline = { "dashboard", "alpha", "ministarter", "snacks_dashboard" } },
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = { "branch" },

        lualine_c = {
          LazyVim.lualine.root_dir(),
          {
            "diagnostics",
            symbols = {
              error = icons.diagnostics.Error,
              warn = icons.diagnostics.Warn,
              info = icons.diagnostics.Info,
              hint = icons.diagnostics.Hint,
            },
          },
          { "filetype", icon_only = true, separator = "", padding = { left = 1, right = 0 } },
          { LazyVim.lualine.pretty_path() },
        },
        lualine_x = {
          Snacks.profiler.status(),
          -- stylua: ignore
          {
            function() return require("noice").api.status.command.get() end,
            cond = function() return package.loaded["noice"] and require("noice").api.status.command.has() end,
            color = function() return { fg = Snacks.util.color("Statement") } end,
          },
          -- stylua: ignore
          {
            function() return require("noice").api.status.mode.get() end,
            cond = function() return package.loaded["noice"] and require("noice").api.status.mode.has() end,
            color = function() return { fg = Snacks.util.color("Constant") } end,
          },
          -- stylua: ignore
          {
            function() return "  " .. require("dap").status() end,
            cond = function() return package.loaded["dap"] and require("dap").status() ~= "" end,
            color = function() return { fg = Snacks.util.color("Debug") } end,
          },
          -- stylua: ignore
          {
            require("lazy.status").updates,
            cond = require("lazy.status").has_updates,
            color = function() return { fg = Snacks.util.color("Special") } end,
          },
          {
            "diff",
            symbols = {
              added = icons.git.added,
              modified = icons.git.modified,
              removed = icons.git.removed,
            },
            source = function()
              local gitsigns = vim.b.gitsigns_status_dict
              if gitsigns then
                return {
                  added = gitsigns.added,
                  modified = gitsigns.changed,
                  removed = gitsigns.removed,
                }
              end
            end,
          },
        },
        lualine_y = {
          { "progress", separator = " ", padding = { left = 1, right = 0 } },
          { "location", padding = { left = 0, right = 1 } },
        },
        lualine_z = {
          function()
            return " " .. os.date("%R")
          end,
        },
      },
      extensions = { "neo-tree", "lazy", "fzf" },
    }

    -- do not add trouble symbols if aerial is enabled
    -- And allow it to be overriden for some buffer types (see autocmds)
    if vim.g.trouble_lualine and LazyVim.has("trouble.nvim") then
      local trouble = require("trouble")
      local symbols = trouble.statusline({
        mode = "symbols",
        groups = {},
        title = false,
        filter = { range = true },
        format = "{kind_icon}{symbol.name:Normal}",
        hl_group = "lualine_c_normal",
      })
      table.insert(opts.sections.lualine_c, {
        symbols and symbols.get,
        cond = function()
          return vim.b.trouble_lualine ~= false and symbols.has()
        end,
      })
    end
    -- table.insert(opts.sections.lualine_x, "venv-selector")
    table.insert(opts.sections.lualine_x, { "venv-selector", icon = "\u{e606}", color = { fg = "#50f872" } })

    return opts
  end,
}
