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
      -- enabled = true,
      preset = {
        --      header = [[
        --                                              ───▐▀▄──────▄▀▌───▄▄▄▄▄▄▄
        --      ██╗ █████╗ ██████╗  ██████╗  ██████╗    ───▌▒▒▀▄▄▄▄▀▒▒▐▄▀▀▒██▒██▒▀▀▄
        --      ██║██╔══██╗██╔══██╗██╔═══██╗██╔═══██╗   ──▌▒▒▒▒▒▒▒▒▒▒▒▒▒▄▒▒▒▒▒▒▒▒▒▒▒▀▄
        --      ██║███████║██████╔╝██║   ██║██║   ██║   ▀█▒▒█▌▒▒█▒▒▐█▒▒▀▒▒▒▒▒▒▒▒▒▒▒▒▒▒▌
        -- ██   ██║██╔══██║██╔══██╗██║   ██║██║   ██║   ▀▌▒▒▒▒▒▀▒▀▒▒▒▒▒▀▀▒▒▒▒▒▒▒▒▒▒▒▒▒▐ ▄▄
        -- ╚█████╔╝██║  ██║██████╔╝╚██████╔╝╚██████╔╝    ▐▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▄█▒█
        --  ╚════╝ ╚═╝  ╚═╝╚═════╝  ╚═════╝  ╚═════╝   ──▐▄▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▄▌
        --  ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀   ────▀▄▄▀▀▀▀▄▄▀▀▀▀▀▀▄▄▀▀▀▀▀▀▄▄▀
        --      ]],
        header = [[
░▒▓█▓▒░░▒▓█▓▒░░▒▓█▓▒░  ░▒▓██████▓▒░  ░▒▓███████▓▒░   ░▒▓██████▓▒░  ░▒▓█▓▒░░▒▓█▓▒░ ░▒▓█▓▒░        
░▒▓█▓▒░░▒▓█▓▒░░▒▓█▓▒░ ░▒▓█▓▒░░▒▓█▓▒░ ░▒▓█▓▒░░▒▓█▓▒░ ░▒▓█▓▒░░▒▓█▓▒░ ░▒▓█▓▒░░▒▓█▓▒░ ░▒▓█▓▒░        
░▒▓█▓▒░░▒▓█▓▒░░▒▓█▓▒░ ░▒▓█▓▒░░▒▓█▓▒░ ░▒▓█▓▒░░▒▓█▓▒░ ░▒▓█▓▒░        ░▒▓█▓▒░░▒▓█▓▒░ ░▒▓█▓▒░        
░▒▓█▓▒░░▒▓█▓▒░░▒▓█▓▒░ ░▒▓████████▓▒░ ░▒▓█▓▒░░▒▓█▓▒░ ░▒▓█▓▒▒▓███▓▒░ ░▒▓████████▓▒░ ░▒▓█▓▒░        
░▒▓█▓▒░░▒▓█▓▒░░▒▓█▓▒░ ░▒▓█▓▒░░▒▓█▓▒░ ░▒▓█▓▒░░▒▓█▓▒░ ░▒▓█▓▒░░▒▓█▓▒░ ░▒▓█▓▒░░▒▓█▓▒░ ░▒▓█▓▒░        
░▒▓█▓▒░░▒▓█▓▒░░▒▓█▓▒░ ░▒▓█▓▒░░▒▓█▓▒░ ░▒▓█▓▒░░▒▓█▓▒░ ░▒▓█▓▒░░▒▓█▓▒░ ░▒▓█▓▒░░▒▓█▓▒░ ░▒▓█▓▒░        
 ░▒▓█████████████▓▒░  ░▒▓█▓▒░░▒▓█▓▒░ ░▒▓█▓▒░░▒▓█▓▒░  ░▒▓██████▓▒░  ░▒▓█▓▒░░▒▓█▓▒░ ░▒▓████████▓▒░ 
                                                                                                 
           ]],
      },
    },
    image = {},
    indent = {
      scope = {
        enabled = false,
        only_current = false, -- only show scope in the current window
      },
      animate = { enabled = false },
    },
    scroll = {
      enabled = false,
    },
    explorer = {
      -- enabled = false,
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
    statuscolumn = {},
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
