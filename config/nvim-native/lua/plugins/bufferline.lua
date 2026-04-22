vim.pack.add({
	{ src = "https://github.com/akinsho/bufferline.nvim" },
})
vim.api.nvim_create_autocmd({ "BufReadPre", "BufNewFile" }, {
	group = vim.api.nvim_create_augroup("SetupBufferline", { clear = true }),
	once = true,
	callback = function()
        local bufferline = require("bufferline")
		bufferline.setup({
			options = {
				style_preset = bufferline.style_preset.no_italic,
			},
		})
	end,
})

vim.api.nvim_create_autocmd({ "BufAdd", "BufDelete" }, {
	callback = function()
		vim.schedule(function()
			pcall(nvim_bufferline)
		end)
	end,
})

local map = function(key, act, desc)
	vim.keymap.set("n", key, act, { desc = desc })
end
map("<leader>bp", "<Cmd>BufferLineTogglePin<CR>", "Toggle Pin")
map("<leader>bP", "<Cmd>BufferLineGroupClose ungrouped<CR>", "Delete Non-Pinned Buffers")
map("<leader>br", "<Cmd>BufferLineCloseRight<CR>", "Delete Buffers to the Right")
map("<leader>bl", "<Cmd>BufferLineCloseLeft<CR>", "Delete Buffers to the Left")
map("<S-h>", "<cmd>BufferLineCyclePrev<cr>", "Prev Buffer")
map("<S-l>", "<cmd>BufferLineCycleNext<cr>", "Next Buffer")
map("[b", "<cmd>BufferLineCyclePrev<cr>", "Prev Buffer")
map("]b", "<cmd>BufferLineCycleNext<cr>", "Next Buffer")
map("[B", "<cmd>BufferLineMovePrev<cr>", "Move buffer prev")
map("]B", "<cmd>BufferLineMoveNext<cr>", "Move buffer next")
