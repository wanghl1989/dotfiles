vim.pack.add({
	{ src = "https://github.com/folke/snacks.nvim" },
})
-- Picker
local Snacks = require("snacks")
Snacks.setup({
	explorer = { enabled = false },
	notifier = {
		enabled = true,
		timeout = 3000,
	},
	input = {
		enabled = true,
	},
	statuscolumn = { enabled = true },
	scroll = { enabled = true },
	picker = {
		matcher = { frecency = true, cwd_bonus = true, history_bonus = true },
        formatters = {
            file = {
            filename_first = true,
            truncate = 100,
            },
        },
		win = {
			input = {
				keys = {
					["<C-T>"] = { "edit_tab", mode = { "n", "i" } },
				},
			},
		},
	},
	dashboard = {
		enabled = true,
		preset = {
			keys = {
				{ icon = "󰈞 ", key = "f", desc = "Find files", action = ":lua Snacks.picker.smart()" },
				{ icon = " ", key = "o", desc = "Find history", action = "lua Snacks.picker.recent()" },
				{ icon = " ", key = "e", desc = "Exlplore", action = ":Oil ." },
				{ icon = " ", key = "o", desc = "Recent files", action = ":lua Snacks.picker.recent()" },
				{ icon = " ", key = "m", desc = "Mason", action = ":Mason" },
				{ icon = " ", key = "q", desc = "Quit", action = ":qa" },
			},
			header = [[
                                                                   
      ████ ██████           █████      ██                w.hl
     ███████████             █████                            
     █████████ ███████████████████ ███   ███████████  
    █████████  ███    █████████████ █████ ██████████████  
   █████████ ██████████ █████████ █████ █████ ████ █████  
 ███████████ ███    ███ █████████ █████ █████ ████ █████ 
██████  █████████████████████ ████ █████ █████ ████ ██████
]],
		},
		sections = {
			{ section = "header" },
			{ icon = " ", title = "Keymaps", section = "keys", indent = 2, padding = 1 },
		},
	},
	image = {
		enabled = true,
		doc = { enabled = true, inline = false, float = false, max_width = 80, max_height = 20 },
	},
	indent = {
		enabled = true,
	},
	styles = {
		snacks_image = {
			border = "rounded",
			backdrop = false,
		},
	},
})
local map = function(key, func, desc)
	vim.keymap.set("n", key, func, { desc = desc })
end

map("<leader>fs", function()
	local bufnr = vim.api.nvim_get_current_buf()
	local clients = vim.lsp.get_clients({ bufnr = bufnr })

	local function has_lsp_symbols()
		for _, client in ipairs(clients) do
			if client.server_capabilities.documentSymbolProvider then
				return true
			end
		end
		return false
	end

	if has_lsp_symbols() then
		Snacks.picker.lsp_symbols({
			layout = "dropdown",
			tree = true,
			-- on_show = function()
			--   vim.cmd.stopinsert()
			-- end,
		})
	else
		Snacks.picker.treesitter()
	end
end, "Find symbol in current buffer")

map("<leader><space>", function()
	Snacks.picker.smart()
end, "Smart Find Files")
map("<leader>,", function()
	Snacks.picker.buffers()
end, "Buffers")
map("<leader>/", function()
	Snacks.picker.grep()
end, "Grep")
map("<leader>:", function()
	Snacks.picker.command_history()
end, "Command History")
map("<leader>nl", function()
	Snacks.picker.notifications()
end, "Notification History")
-- find
map("<leader>fb", function()
	Snacks.picker.buffers()
end, "Buffers")
map("<leader>fc", function()
	Snacks.picker.files({ cwd = vim.fn.stdpath("config") })
end, "Find Config File")
map("<leader>ff", function()
	Snacks.picker.files()
end, "Find Files")
map("<leader>fg", function()
	Snacks.picker.git_files()
end, "Find Git Files")
map("<leader>fp", function()
	Snacks.picker.projects()
end, "Projects")
map("<leader>fr", function()
	Snacks.picker.recent()
end, "Recent")
-- git
map("<leader>gb", function()
	Snacks.picker.git_branches()
end, "Git Branches")
map("<leader>gl", function()
	Snacks.picker.git_log()
end, "Git Log")
map("<leader>gL", function()
	Snacks.picker.git_log_line()
end, "Git Log Line")
map("<leader>gs", function()
	Snacks.picker.git_status()
end, "Git Status")
map("<leader>gS", function()
	Snacks.picker.git_stash()
end, "Git Stash")
map("<leader>gd", function()
	Snacks.picker.git_diff()
end, "Git Diff (Hunks)")
map("<leader>gf", function()
	Snacks.picker.git_log_file()
end, "Git Log File")
-- gh
map("<leader>gi", function()
	Snacks.picker.gh_issue()
end, "GitHub Issues (open)")
map("<leader>gI", function()
	Snacks.picker.gh_issue({ state = "all" })
end, "GitHub Issues (all)")
map("<leader>gp", function()
	Snacks.picker.gh_pr()
end, "GitHub Pull Requests (open)")
map("<leader>gP", function()
	Snacks.picker.gh_pr({ state = "all" })
end, "GitHub Pull Requests (all)")
-- Grep
map("<leader>sb", function()
	Snacks.picker.lines()
end, "Buffer Lines")
map("<leader>sB", function()
	Snacks.picker.grep_buffers()
end, "Grep Open Buffers")
map("<leader>sg", function()
	Snacks.picker.grep()
end, "Grep")
vim.keymap.set({ "n", "x" }, "<leader>sw", function()
	Snacks.picker.grep_word()
end, { desc = "Visual selection or word" })
-- search
map('<leader>s"', function()
	Snacks.picker.registers()
end, "Registers")
map("<leader>s/", function()
	Snacks.picker.search_history()
end, "Search History")
map("<leader>sa", function()
	Snacks.picker.autocmds()
end, "Autocmds")
map("<leader>sb", function()
	Snacks.picker.lines()
end, "Buffer Lines")
map("<leader>sc", function()
	Snacks.picker.command_history()
end, "Command History")
map("<leader>sC", function()
	Snacks.picker.commands()
end, "Commands")
map("<leader>sd", function()
	Snacks.picker.diagnostics()
end, "Diagnostics")
map("<leader>sD", function()
	Snacks.picker.diagnostics_buffer()
end, "Buffer Diagnostics")
map("<leader>sh", function()
	Snacks.picker.help()
end, "Help Pages")
map("<leader>sH", function()
	Snacks.picker.highlights()
end, "Highlights")
map("<leader>si", function()
	Snacks.picker.icons()
end, "Icons")
map("<leader>sj", function()
	Snacks.picker.jumps()
end, "Jumps")
map("<leader>sk", function()
	Snacks.picker.keymaps()
end, "Keymaps")
map("<leader>sl", function()
	Snacks.picker.loclist()
end, "Location List")
map("<leader>sm", function()
	Snacks.picker.marks()
end, "Marks")
map("<leader>sM", function()
	Snacks.picker.man()
end, "Man Pages")
map("<leader>sp", function()
	Snacks.picker.lazy()
end, "Search for Plugin Spec")
map("<leader>sq", function()
	Snacks.picker.qflist()
end, "Quickfix List")
map("<leader>sR", function()
	Snacks.picker.resume()
end, "Resume")
map("<leader>su", function()
	Snacks.picker.undo()
end, "Undo History")
map("<leader>uC", function()
	Snacks.picker.colorschemes()
end, "Colorschemes")
-- LSP
map("gd", function()
	Snacks.picker.lsp_definitions()
end, "Goto Definition")
map("gD", function()
	Snacks.picker.lsp_declarations()
end, "Goto Declaration")
vim.keymap.set("n", "gr", function()
	Snacks.picker.lsp_references()
end, { desc = "Reference", nowait = true })
map("gI", function()
	Snacks.picker.lsp_implementations()
end, "Goto Implementation")
map("gy", function()
	Snacks.picker.lsp_type_definitions()
end, "Goto T[y]pe Definition")
map("gai", function()
	Snacks.picker.lsp_incoming_calls()
end, "C[a]lls Incoming")
map("gao", function()
	Snacks.picker.lsp_outgoing_calls()
end, "C[a]lls Outgoing")
map("<leader>ss", function()
	Snacks.picker.lsp_symbols()
end, "LSP Symbols")
map("<leader>sS", function()
	Snacks.picker.lsp_workspace_symbols()
end, "LSP Workspace Symbols")
-- Other
map("<leader>z", function()
	Snacks.zen()
end, "Toggle Zen Mode")
map("<leader>Z", function()
	Snacks.zen.zoom()
end, "Toggle Zoom")
map("<leader>.", function()
	Snacks.scratch()
end, "Toggle Scratch Buffer")
map("<leader>S", function()
	Snacks.scratch.select()
end, "Select Scratch Buffer")
map("<leader>ns", function()
	Snacks.notifier.show_history()
end, "Notification History")
map("<leader>bd", function()
	Snacks.bufdelete()
end, "Delete Buffer")
map("<leader>cR", function()
	Snacks.rename.rename_file()
end, "Rename File")
vim.keymap.set({ "n", "v" }, "<leader>gB", function()
	Snacks.gitbrowse()
end, { desc = "Git Browse" })
map("<leader>gg", function()
	Snacks.lazygit()
end, "Lazygit")
map("<leader>nc", function()
	Snacks.notifier.hide()
end, "Dismiss All Notifications")


vim.keymap.set({ "n", "t" }, "<c-/>", function()
	Snacks.terminal()
end, { desc = "Toggle Terminal" })

vim.keymap.set({ "n", "t" }, "<c-t>", function()
	Snacks.terminal()
end, { desc = "Toggle Terminal" })

vim.keymap.set({ "n", "t" }, "]]", function()
	Snacks.words.jump(vim.v.count1)
end, { desc = "Next Reference" })
vim.keymap.set({ "n", "t" }, "[[", function()
	Snacks.words.jump(-vim.v.count1)
end, { desc = "Prev Reference" })
