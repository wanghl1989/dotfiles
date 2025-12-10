-- Snacks.nvim configuration
-- Provides dashboard, indent guides, and file picker
return {
  "snacks.nvim",
  opts = {
    dashboard = {
      preset = {
        header = [[
                                                ───▐▀▄──────▄▀▌───▄▄▄▄▄▄▄          
        ██╗ █████╗ ██████╗  ██████╗  ██████╗    ───▌▒▒▀▄▄▄▄▀▒▒▐▄▀▀▒██▒██▒▀▀▄       
        ██║██╔══██╗██╔══██╗██╔═══██╗██╔═══██╗   ──▌▒▒▒▒▒▒▒▒▒▒▒▒▒▄▒▒▒▒▒▒▒▒▒▒▒▀▄     
        ██║███████║██████╔╝██║   ██║██║   ██║   ▀█▒▒█▌▒▒█▒▒▐█▒▒▀▒▒▒▒▒▒▒▒▒▒▒▒▒▒▌    
   ██   ██║██╔══██║██╔══██╗██║   ██║██║   ██║   ▀▌▒▒▒▒▒▀▒▀▒▒▒▒▒▀▀▒▒▒▒▒▒▒▒▒▒▒▒▒▐ ▄▄ 
   ╚█████╔╝██║  ██║██████╔╝╚██████╔╝╚██████╔╝    ▐▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▄█▒█
    ╚════╝ ╚═╝  ╚═╝╚═════╝  ╚═════╝  ╚═════╝   ──▐▄▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▄▌    
    ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀   ────▀▄▄▀▀▀▀▄▄▀▀▀▀▀▀▄▄▀▀▀▀▀▀▄▄▀      
        ]],
      },
    },
    image = {},
    indent = {
      scope = { enabled = false },
      animate = { enabled = false },
    },
    scroll = {
      enabled = false,
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
          dev = { "~/Code", "~/Obsidian" },
          max_depth = 3,
        },
      },
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
    {
      "<C-p>",
      function()
        Snacks.picker.files({ hidden = true })
      end,
      desc = "Find Files (Root Dir)",
    },
  },
}
