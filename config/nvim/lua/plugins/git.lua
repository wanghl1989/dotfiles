vim.pack.add({
	{ src = "https://github.com/lewis6991/gitsigns.nvim" },
})

require("gitsigns").setup({
	signs = {
		add = { text = "│" },
		change = { text = "│" },
		delete = { text = "_" },
		topdelete = { text = "‾" },
		changedelete = { text = "~" },
		untracked = { text = "┆" },
	},
	signs_staged = {
		add = { text = "│" },
		change = { text = "│" },
		delete = { text = "_" },
		topdelete = { text = "‾" },
		changedelete = { text = "~" },
		untracked = { text = "┆" },
	},
	signcolumn = true,
	linehl = false,
	word_diff = false,
	current_line_blame = true,
	current_line_blame_formatter = "		 <author_mail>, <author_time:%Y-%m-%d> • <summary> • <abbrev_sha>",
	on_attach = function(bufnr)
		local gitsigns = require("gitsigns")
		local function map(mode, l, r, opts)
			opts = opts or {}
			opts.buffer = bufnr
			opts.silent = true
			vim.keymap.set(mode, l, r, opts)
		end

		-- Git menu aliases keep all Git actions discoverable under <leader>g.
		map("n", "<leader>gj", function() gitsigns.nav_hunk("next") end, { desc = "Next Git hunk" })
		map("n", "<leader>gk", function() gitsigns.nav_hunk("prev") end, { desc = "Previous Git hunk" })
		map("n", "<leader>gp", gitsigns.preview_hunk, { desc = "Preview Git hunk" })
		map("n", "<leader>gb", function() gitsigns.blame_line({ full = true }) end, { desc = "Blame current line" })
		map("n", "<leader>gd", gitsigns.diffthis, { desc = "Diff against Git index" })
		map("n", "<leader>gq", gitsigns.setqflist, { desc = "List file hunks in quickfix" })
		map("n", "<leader>gs", gitsigns.stage_hunk, { desc = "Stage / unstage Git hunk" })
		map("x", "<leader>gs", function()
			gitsigns.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
		end, { desc = "Stage / unstage selected lines" })
		map("n", "<leader>gr", gitsigns.reset_hunk, { desc = "Reset Git hunk" })
		map({ "o", "x" }, "ih", gitsigns.select_hunk, { desc = "Select Git hunk" })

		-- Navigation
		map("n", "]h", function()
			if vim.wo.diff then
				vim.cmd.normal({ "]c", bang = true })
			else
				gitsigns.nav_hunk("next")
			end
		end, { desc = "[Gitsigns]: Next Hunk" })

		map("n", "[h", function()
			if vim.wo.diff then
				vim.cmd.normal({ "[c", bang = true })
			else
				gitsigns.nav_hunk("prev")
			end
		end, { desc = "[Gitsigns]: Previous Hunk" })

		map("n", "<leader>hp", gitsigns.preview_hunk_inline, { desc = "[Gitsigns]: Preview Hunk Inline" })

		map("n", "<leader>hb", function()
			gitsigns.blame_line({ full = true })
		end, { desc = "[Gitsigns]: Show Blame Line" })
	end,
})

-- Project-wide pickers are global, including buffers without Gitsigns attached.
vim.keymap.set("n", "<leader>gh", function()
	require("mini.extra").pickers.git_hunks({ scope = "unstaged" })
end, { desc = "Search project Git hunks (unstaged)" })
vim.keymap.set("n", "<leader>gH", function()
	require("mini.extra").pickers.git_hunks({ scope = "staged" })
end, { desc = "Search project Git hunks (staged)" })
vim.keymap.set("n", "<leader>gu", function()
	require("mini.extra").pickers.git_files({ scope = "untracked" })
end, { desc = "Search untracked Git files" })
