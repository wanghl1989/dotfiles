return {
  {
    "jake-stewart/multicursor.nvim",
    branch = "1.0",
    config = function()
      local mc = require("multicursor-nvim")
      mc.setup()

      local set = vim.keymap.set

      -- Add or skip cursor above/below the main cursor.
      set({ "n", "x" }, "<leader>vk", function()
        mc.lineAddCursor(-1)
      end, { noremap = true, desc = "Line add cursor previous" })
      set({ "n", "x" }, "<leader>vj", function()
        mc.lineAddCursor(1)
      end, { noremap = true, desc = "Line add cursor next" })
      set({ "n", "x" }, "<leader>vK", function()
        mc.lineSkipCursor(-1)
      end, { noremap = true, desc = "Line skip cursor previous" })
      set({ "n", "x" }, "<leader>vJ", function()
        mc.lineSkipCursor(1)
      end, { noremap = true, desc = "Line skip cursor next" })

      -- Add or skip adding a new cursor by matching word/selection
      set({ "n", "x" }, "<leader>vl", function()
        mc.matchAddCursor(1)
      end, { noremap = true, desc = "Match add cursor next" })
      set({ "n", "x" }, "<leader>vh", function()
        mc.matchAddCursor(-1)
      end, { noremap = true, desc = "Match add cursor previous" })
      set({ "n", "x" }, "<leader>vL", function()
        mc.matchSkipCursor(1)
      end, { noremap = true, desc = "Match skip cursor next" })
      set({ "n", "x" }, "<leader>vH", function()
        mc.matchSkipCursor(-1)
      end, { noremap = true, desc = "Match skip cursor previous" })

      -- Add and remove cursors with control + left click.
      set("n", "<c-leftmouse>", mc.handleMouse)
      set("n", "<c-leftdrag>", mc.handleMouseDrag)
      set("n", "<c-leftrelease>", mc.handleMouseRelease)

      -- Disable and enable cursors.
      set({ "n", "x" }, "<leader>mm", mc.toggleCursor, { desc = "Toggle multi cursor mode" })

      -- Mappings defined in a keymap layer only apply when there are
      -- multiple cursors. This lets you have overlapping mappings.
      mc.addKeymapLayer(function(layerSet)
        -- Select a different cursor as the main one.
        layerSet({ "n", "x" }, "<left>", mc.prevCursor)
        layerSet({ "n", "x" }, "<right>", mc.nextCursor)

        -- Delete the main cursor.
        layerSet({ "n", "x" }, "<leader>x", mc.deleteCursor)

        -- Enable and clear cursors using escape.
        layerSet("n", "<esc>", function()
          if not mc.cursorsEnabled() then
            mc.enableCursors()
          else
            mc.clearCursors()
          end
        end)
      end)

      -- Customize how cursors look.
      local hl = vim.api.nvim_set_hl
      hl(0, "MultiCursorCursor", { reverse = true })
      hl(0, "MultiCursorVisual", { link = "Visual" })
      hl(0, "MultiCursorSign", { link = "SignColumn" })
      hl(0, "MultiCursorMatchPreview", { link = "Search" })
      hl(0, "MultiCursorDisabledCursor", { reverse = true })
      hl(0, "MultiCursorDisabledVisual", { link = "Visual" })
      hl(0, "MultiCursorDisabledSign", { link = "SignColumn" })
    end,
  },
}
