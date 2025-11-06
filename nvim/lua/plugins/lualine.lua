-- Lualine word count extension
-- Shows word count in the status line for text files
return {
  "nvim-lualine/lualine.nvim",
  event = "VeryLazy",
  opts = function(_, opts)
    local function is_textfile()
      local filetype = vim.bo.filetype
      return filetype == "markdown"
        or filetype == "asciidoc"
        or filetype == "pandoc"
        or filetype == "tex"
        or filetype == "text"
    end

    local function wordcount()
      local wc = vim.fn.wordcount()
      local visual_words = wc.visual_words or wc.words
      local word_string = visual_words == 1 and " word" or " words"
      return tostring(visual_words) .. word_string
    end

    -- local function is_pythonfile()
    --   local filetype = vim.bo.filetype
    --   return filetype == "py" or filetype == "pyi" or filetype == "pyw"
    -- end
    --
    -- local function venvSelect()
    --   local venv_path = require("venv-selector").venv()
    --   if not venv_path or venv_path == "" then
    --     return ""
    --   end
    --
    --   local venv_name = vim.fn.fnamemodify(venv_path, ":t")
    --   if not venv_name then
    --     return ""
    --   end
    --
    --   local output = "🐍 " .. venv_name .. " " -- Changes only the icon but you can change colors or use powerline symbols here.
    --   return output
    -- end

    table.insert(opts.sections.lualine_z, { wordcount, cond = is_textfile })
    -- table.insert(opts.sections.lualine_x, { venvSelect, cond = is_pythonfile,  icon = "\u{1f332}", color = { fg = "#7fb55e" }  })
    table.insert(opts.sections.lualine_x, { "venv-selector", icon = "\u{1f332}", color = { fg = "#7fb55e" } })

    -- Update the pretty_path component to not truncate filenames
    -- Replace the existing pretty_path component in lualine_c
    opts.sections.lualine_c[4] = { LazyVim.lualine.pretty_path({ length = 0 }) }
  end,
}
