vim.pack.add({
	{ src = "https://github.com/akinsho/bufferline.nvim" },
})

vim.api.nvim_create_autocmd({ "BufReadPre", "BufNewFile" }, {
	group = vim.api.nvim_create_augroup("SetupBufferline", { clear = true }),
	once = true,
	callback = function()
		local bufferline = require("bufferline")
		local colors = require('material.colors')
		-- active 背景:用调色板里真实存在的 editor.border,
		-- 比 editor.bg(#0F111A)明显亮一档,确保选中项可见。
		-- 注意:旧配置用的 colors.bg0 在 material 里不存在,会是 nil。
		local active_bg = colors.editor.border

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
				-- 选中的 buffer:白色文字 + 明显背景,确保可见
				buffer_selected = {
					fg = colors.white,
					bg = active_bg,
					bold = true,
				},
				-- 未选中的 tab(标签页)
				tab = {
					bg = "none",
					fg = colors.editor.fg_dark,
				},
				-- 选中的 tab:与选中 buffer 相同的背景
				tab_selected = {
					fg = colors.white,
					bg = active_bg,
					bold = true,
				},
				tab_separator = {
					fg = "none",
					bg = "none",
				},
				tab_separator_selected = {
					bg = "none",
					fg = active_bg,
				},
				close_button_selected = {
					fg = colors.white,
				},
				-- 分隔符:fg 设为背景色以融入背景;选中项旁的分隔符融入 active 背景
				separator = {
					fg = colors.editor.bg,
					bg = "none",
				},
				separator_selected = {
					fg = active_bg,
					bg = "none",
				},
				separator_visible = {
					fg = colors.editor.bg,
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
map("<leader>bo", "<Cmd>BufferLineCloseOthers<CR>", "Delete Other Buffers")
map("<S-h>", "<cmd>BufferLineCyclePrev<cr>", "Prev Buffer")
map("<S-l>", "<cmd>BufferLineCycleNext<cr>", "Next Buffer")
map("[b", "<cmd>BufferLineCyclePrev<cr>", "Prev Buffer")
map("]b", "<cmd>BufferLineCycleNext<cr>", "Next Buffer")
map("[B", "<cmd>BufferLineMovePrev<cr>", "Move buffer prev")
map("]B", "<cmd>BufferLineMoveNext<cr>", "Move buffer next")
