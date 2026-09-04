vim.pack.add({
	{ src = "https://github.com/MunifTanjim/nui.nvim" },
	{ src = "https://github.com/folke/noice.nvim" },
	{ src = "https://github.com/sphamba/smear-cursor.nvim" },
})

require("smear_cursor").setup({
	stiffness = 0.5,
	trailing_stiffness = 0.2,
	trailing_exponent = 5,
	damping = 0.6,
	hide_target_hack = true, -- same
	min_distance_emit_particles = 0,
})

vim.api.nvim_create_autocmd({ "UIEnter" }, {
	group = vim.api.nvim_create_augroup("SetupExtraUI", { clear = true }),
	callback = function()
		vim.schedule(function()
			require("noice").setup({
				lsp = {
					progress = {
						enabled = false,
					},
					hover = {
						-- Multiple Python clients can answer the same hover request;
						-- do not notify when one returns empty and another has content.
						silent = true,
					},
					override = {
						["vim.lsp.util.convert_input_to_markdown_lines"] = true,
						["vim.lsp.util.stylize_markdown"] = true,
						["cmp.entry.get_documentation"] = true,
					},
				},
				notify = {
					enabled = false,
				},
				message = {
					enabled = true,
				},
				routes = {
					{
						filter = {
							event = "msg_show",
							any = {
								{ find = "%d+L, %d+B" },
								{ find = "; after #%d+" },
								{ find = "; before #%d+" },
							},
						},
						view = "mini",
					},
				},
				presets = {
					bottom_search = true,
					command_palette = false,
					long_message_to_split = false,
				},
			})
		end)
	end,
})
