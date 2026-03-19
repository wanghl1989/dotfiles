return {
  {
    "stevearc/oil.nvim",
    ---@module 'oil'
    ---@type oil.SetupOpts
    opts = {
      default_file_explorer = true,
      delete_to_trash = true,
      columns = {
        "icon", -- 文件图标（可选，删掉就是纯文本ls）
        "permissions", -- 文件权限（rwxr-xr-x）
        "size", -- 文件大小（人性化，ls -h）
        "mtime", -- 修改时间
      },
      view_options = {
        -- Show files and directories that start with "."
        show_hidden = false,
      },
      show_file_highlights = true,
      show_directory_highlights = false,
      show_ignored_files = true,
      keymaps = {
        ["g?"] = { "actions.show_help", mode = "n" },
        ["<CR>"] = "actions.select",
        ["<S-l>"] = "actions.select",
        ["<C-s>"] = { "actions.select", opts = { vertical = true } },
        ["<C-h>"] = { "actions.select", opts = { horizontal = true } },
        ["<C-t>"] = { "actions.select", opts = { tab = true } },
        ["<S-j>"] = "actions.preview",
        ["<C-c>"] = { "actions.close", mode = "n" },
        ["<C-l>"] = "actions.refresh",
        ["<S-h>"] = { "actions.parent", mode = "n" },
        ["<S-k>"] = { "actions.open_cwd", mode = "n" },
        ["`"] = { "actions.cd", mode = "n" },
        ["g~"] = { "actions.cd", opts = { scope = "tab" }, mode = "n" },
        ["gs"] = { "actions.change_sort", mode = "n" },
        ["gx"] = "actions.open_external",
        ["g."] = { "actions.toggle_hidden", mode = "n" },
        ["g\\"] = { "actions.toggle_trash", mode = "n" },
      },
    },
    lazy = false,
  },
  { "malewicz1337/oil-git.nvim", opts = {} },
}
