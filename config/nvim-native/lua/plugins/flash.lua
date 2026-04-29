vim.pack.add({
	{ src = "https://github.com/folke/flash.nvim" },
})

vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
	group = vim.api.nvim_create_augroup("SetupFlash", { clear = true }),
	once = true,
	callback = function()
		local flash = require("flash")
		flash.setup({
			label = {
				rainbow = {
					enabled = true,
					shade = 1,
				},
			},
			modes = {
				char = {
					enabled = true, -- 自动接管原生的 f/F/t/T
					jump_labels = true,
				},
			},
		})
		vim.keymap.set({ "n", "x", "o" }, "s", function()
			flash.jump()
		end, { desc = "[Flash]: Flash Jump" })

		vim.keymap.set({ "n", "x", "o" }, "S", function()
			flash.treesitter()
		end, { desc = "Flash Treesitter" })

		vim.keymap.set("o", "r", function()
			flash.remote()
		end, { desc = "Treesitter Search" })

		vim.keymap.set({ "o", "x" }, "R", function()
			flash.treesitter_search()
		end, { desc = "Treesitter Search" })

		vim.keymap.set("c", "<c-s>", function()
			flash.toggle()
		end, { desc = "Toggle Flash Search" })

		vim.keymap.set({ "n", "o", "x" }, "<c-space>", function()
			flash.treesitter({
				actions = {
					["<c-space>"] = "next",
					["<BS>"] = "prev",
				},
			})
		end, { desc = "Treesitter Incremental Selection" })
	end,
})
