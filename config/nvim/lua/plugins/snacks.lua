-- Snacks.nvim configuration
-- Provides dashboard, indent guides, and file picker

local excluded = {
  "node_modules/",
  "dist/",
  ".next/",
  ".vite/",
  ".git/",
  ".gitlab/",
  "build/",
  "target/",
  "dadbod_ui/tmp/",
  "dadbod_ui/dev/",

  -- ISSUE: these FILES are being hidden from snacks.explorer too.
  "package-lock.json",
  "pnpm-lock.yaml",
  "yarn.lock",
  ".venv/",
  "venv/",
  "target/",
  ".vscode/",
  ".claude/",
}

return {
  "snacks.nvim",
  opts = {
    dashboard = {
      enabled = true,
      width = 18,
      preset = {
        header = [[
                                                                   
      ████ ██████           █████      ██                w.hl
     ███████████             █████                            
     █████████ ███████████████████ ███   ███████████  
    █████████  ███    █████████████ █████ ██████████████  
   █████████ ██████████ █████████ █████ █████ ████ █████  
 ███████████ ███    ███ █████████ █████ █████ ████ █████ 
██████  █████████████████████ ████ █████ █████ ████ ██████
]],
      },
    },
    image = {
      enabled = true,
      doc = { enabled = true, inline = false, float = false, max_width = 80, max_height = 20 },
    },
    indent = {
      indent = {
        only_scope = false, -- only show indent guides of the scope
        only_current = true, -- only show indent guides in the current window
      },
      animate = {
        enabled = false,
      },
    },
    animate = {
      enabled = false,
    },
    scroll = {
      enabled = false,
    },
    explorer = {
      enabled = false,
      replace_netrw = false,
    },
    picker = {
      formatters = {
        file = {
          filename_first = true,
          truncate = 100,
        },
      },
      sources = {
        files = {
          hidden = true,
          ignored = false,
        },
        explorer = {
          ignored = true,
        },
        projects = {
          patterns = {
            ".obsidian",
            "go.mod",
            ".git",
            "Makefile",
            "package.json",
            ".bzr",
            ".hg",
            ".svn",
            "_darcs",
          },
          dev = { "~/workspace/", "~/Obsidian" },
          max_depth = 3,
        },
      },
      exclude = excluded,
      ignored = false,
      hidden = true,
    },
    statuscolumn = { enabled = true },
    lazygit = {
      configure = true,
      theme = {
        [241] = { fg = "Special" },
        activeBorderColor = { fg = "MatchParen", bold = true },
        cherryPickedCommitBgColor = { fg = "Identifier" },
        cherryPickedCommitFgColor = { fg = "Function" },
        defaultFgColor = { fg = "Normal" },
        inactiveBorderColor = { fg = "FloatBorder" },
        optionsTextColor = { fg = "Function" },
        searchingActiveBorderColor = { fg = "MatchParen", bold = true },
        selectedLineBgColor = { bg = "Visual" }, -- set to `default` to have no background colour
        unstagedChangesColor = { fg = "DiagnosticError" },
      },
    },
  },
  keys = {
    {
      "<leader>ns",
      function()
        if Snacks.config.picker and Snacks.config.picker.enabled then
          Snacks.picker.notifications()
        else
          Snacks.notifier.show_history()
        end
      end,
      desc = "Notification History",
    },
  },
}
