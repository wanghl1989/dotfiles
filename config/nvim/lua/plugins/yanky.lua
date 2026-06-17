vim.pack.add({
	{ src = "https://github.com/gbprod/yanky.nvim" },
})

require("yanky").setup({
	system_clipboard = {
		sync_with_ring = not vim.env.SSH_CONNECTION,
		clipboard_register = "+",
	},
	highlight = {
		timer = 150,
	},
    ring = {
        storage = "memory"
    }
})


local map = function(key, cmd, mode, desc)
	vim.keymap.set(mode, key, cmd, { desc = desc })
end

map("<leader>sy", "<cmd>YankyRingHistory<CR>", "n",  "Search yanky history")
map("y", "<Plug>(YankyYank)", { "n", "x" }, "Yank Text")
map("p", "<Plug>(YankyPutAfter)", { "n", "x" }, "Put Text After Cursor")
map("P", "<Plug>(YankyPutBefore)", { "n", "x" }, "Put Text Before Cursor")
map("gp", "<Plug>(YankyGPutAfter)", { "n", "x" }, "Put Text After Selection")
map("gP", "<Plug>(YankyGPutBefore)", { "n", "x" }, "Put Text Before Selection")
map("[y", "<Plug>(YankyCycleForward)", "n", "Cycle Forward Through Yank History")
map("]y", "<Plug>(YankyCycleBackward)", "n", "Cycle Backward Through Yank History")
map("]p", "<Plug>(YankyPutIndentAfterLinewise)", "n", "Put Indented After Cursor (Linewise)")
map("[p", "<Plug>(YankyPutIndentBeforeLinewise)", "n", "Put Indented Before Cursor (Linewise)")
map("]P", "<Plug>(YankyPutIndentAfterLinewise)", "n", "Put Indented After Cursor (Linewise)")
map("[P", "<Plug>(YankyPutIndentBeforeLinewise)", "n", "Put Indented Before Cursor (Linewise)")
map(">p", "<Plug>(YankyPutIndentAfterShiftRight)", "n", "Put and Indent Right")
map("<p", "<Plug>(YankyPutIndentAfterShiftLeft)", "n", "Put and Indent Left")
map(">P", "<Plug>(YankyPutIndentBeforeShiftRight)", "n", "Put Before and Indent Right")
map("<P", "<Plug>(YankyPutIndentBeforeShiftLeft)", "n", "Put Before and Indent Left")
map("=p", "<Plug>(YankyPutAfterFilter)", "n", "Put After Applying a Filter")
map("=P", "<Plug>(YankyPutBeforeFilter)", "n", "Put Before Applying a Filter")
