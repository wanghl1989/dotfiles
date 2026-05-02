vim.pack.add({
	{ src = "https://github.com/linux-cultist/venv-selector.nvim" },
})

vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
	group = vim.api.nvim_create_augroup("SetupPython", { clear = true }),
	pattern = { "*.py", "*.pyi" },
	callback = function()
		require("venv-selector").setup({
			search_venv_managers = true,
			search_workspace = true,
			search = {}, -- if you add your own searches, they go here.
			options = {
				notify_user_on_venv_activation = true,
				debug = true,
				statusline_func = {
					lualine = function()
						local venv_path = require("venv-selector").venv()
						if not venv_path or venv_path == "" then
							return ""
						end

						local venv_name = vim.fn.fnamemodify(venv_path, ":t")
						if not venv_name then
							return ""
						end
						return venv_name
					end,
				},
			}, -- if you add plugin options, they go here.
		})
		vim.keymap.set("n", "<leader>cp", "<cmd>:VenvSelect<cr>", { desc = "Select VirtualEnv" })
	end,
})
