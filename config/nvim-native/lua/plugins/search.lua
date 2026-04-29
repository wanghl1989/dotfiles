vim.pack.add({
	{ src = "https://github.com/MagicDuck/grug-far.nvim" },
})

vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
	group = vim.api.nvim_create_augroup("SetupGrepSearch", { clear = true }),
	once = true,
	callback = function()
		require("grug-far").setup({
			headerMaxWidth = 80,
		})

		vim.keymap.set({ "n", "x" }, "<leader>sr", function()
			local grug = require("grug-far")
			local ext = vim.bo.buftype == "" and vim.fn.expand("%:e")
			grug.open({
				transient = true,
				prefills = {
					filesFilter = ext and ext ~= "" and "*." .. ext or nil,
				},
			})
		end, { desc = "Search and Replace" })
	end,
})
