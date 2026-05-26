vim.pack.add({
	{ src = "https://github.com/akinsho/bufferline.nvim" },
})

vim.api.nvim_create_autocmd({ "BufReadPre", "BufNewFile" }, {
	group = vim.api.nvim_create_augroup("SetupBufferline", { clear = true }),
	once = true,
	callback = function()
		local bufferline = require("bufferline")
		local colors = require("gruvbox-material.colors").get(vim.o.background, "hard")

		bufferline.setup({
			options = {
				style_preset = bufferline.style_preset.no_italic,
				separator_style = "thin",
				show_buffer_close_icons = true,
				show_close_icon = false,
				offsets = {
					{
						filetype = "NvimTree",
						text = "File Explorer",
						text_align = "left",
						separator = true,
					},
					{
						filetype = "oil",
						text = "Oil",
						text_align = "left",
						separator = true,
					},
				},
			},
			highlights = {
				buffer_selected = {
					fg = colors.green,
					bold = false,
				},
				tab = {
					bg = "none",
				},
				tab_selected = {
					fg = colors.green,
					bg = colors.bg0,
				},
				tab_separator = {
					fg = colors.bg0,
					bg = "none",
				},
				tab_separator_selected = {
					bg = colors.bg0,
					fg = "none",
				},
				close_button_selected = {
					fg = colors.green,
				},
				separator = {
					fg = colors.bg0,
					bg = "none",
				},
				separator_selected = {
					fg = colors.bg0,
					bg = "none",
				},
				separator_visible = {
					fg = colors.bg0,
					bg = "none",
				},
				indicator_selected = {
					fg = colors.green,
				},
				modified = {
					fg = colors.red,
				},
				modified_visible = {
					fg = colors.red,
				},
				modified_selected = {
					fg = colors.red,
				},
			},
		})
	end,
})

local map = function(key, act, desc)
	vim.keymap.set("n", key, act, { desc = desc })
end
map("<leader>bp", "<Cmd>BufferLineTogglePin<CR>", "Toggle Pin")
map("<leader>bP", "<Cmd>BufferLineGroupClose ungrouped<CR>", "Delete Non-Pinned Buffers")
map("<leader>br", "<Cmd>BufferLineCloseRight<CR>", "Delete Buffers to the Right")
map("<leader>bl", "<Cmd>BufferLineCloseLeft<CR>", "Delete Buffers to the Left")
map("<leader>bo", "<Cmd>BufferLineCloseOthers<CR>", "Delete Buffers to the Left")
map("<S-h>", "<cmd>BufferLineCyclePrev<cr>", "Prev Buffer")
map("<S-l>", "<cmd>BufferLineCycleNext<cr>", "Next Buffer")
map("[b", "<cmd>BufferLineCyclePrev<cr>", "Prev Buffer")
map("]b", "<cmd>BufferLineCycleNext<cr>", "Next Buffer")
map("[B", "<cmd>BufferLineMovePrev<cr>", "Move buffer prev")
map("]B", "<cmd>BufferLineMoveNext<cr>", "Move buffer next")
