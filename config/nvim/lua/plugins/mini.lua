vim.pack.add({
	{ src = "https://github.com/nvim-mini/mini.pick" },
	{ src = "https://github.com/nvim-mini/mini.extra" },
	{ src = "https://github.com/nvim-mini/mini.notify" },
	{ src = "https://github.com/nvim-mini/mini.indentscope" },
	{ src = "https://github.com/nvim-mini/mini.hipatterns" },
	{ src = "https://github.com/nvim-mini/mini.ai" },
	{ src = "https://github.com/nvim-mini/mini.icons" },
	{ src = "https://github.com/nvim-mini/mini.surround" },
	{ src = "https://github.com/nvim-mini/mini.bracketed" },
	{ src = "https://github.com/nvim-mini/mini.pairs" },
	{ src = "https://github.com/nvim-mini/mini.cursorword" },
})
vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
	group = vim.api.nvim_create_augroup("SetupMini", { clear = true }),
	callback = function()
		-- Mini
		require("mini.bracketed").setup()
		require("mini.hipatterns").setup({
			highlighters = {
				-- Highlight standalone 'FIXME', 'HACK', 'TODO', 'NOTE'
				fixme = { pattern = "%f[%w]()FIXME()%f[%W]", group = "MiniHipatternsFixme" },
				hack = { pattern = "%f[%w]()HACK()%f[%W]", group = "MiniHipatternsHack" },
				todo = { pattern = "%f[%w]()TODO()%f[%W]", group = "MiniHipatternsTodo" },
				note = { pattern = "%f[%w]()NOTE()%f[%W]", group = "MiniHipatternsNote" },

				-- Highlight hex color strings (`#rrggbb`) using that color
				hex_color = require("mini.hipatterns").gen_highlighter.hex_color(),
			},
		})
		require("mini.ai").setup({
			mappings = {
				goto_left = "[",
				got_right = "]",
			},
		})

		require("mini.surround").setup({
			mappings = {
				add = "<leader>va", -- Add surrounding in Normal and Visual modes
				delete = "<leader>vd", -- Delete surrounding
				find = "<leader>vfr", -- Find surrounding (to the right)
				find_left = "<leader>vfl", -- Find surrounding (to the left)
				highlight = "<leader>vs", -- Highlight surrounding
				replace = "<leader>vr", -- Replace surrounding
				update_n_lines = "<leader>vn", -- Update `n_lines`
			},
		})

		require("mini.pairs").setup({
			modes = { insert = true, command = false, terminal = false },
			-- skip autopair when next character is one of these
			skip_next = [=[[%w%%%'%[%"%.%`%$]]=],
			-- skip autopair when the cursor is inside these treesitter nodes
			skip_ts = { "string" },
			-- skip autopair when next character is closing pair
			-- and there are more closing pairs than opening pairs
			skip_unbalanced = true,
			-- better deal with markdown code blocks
			markdown = false,
		})

		require("mini.indentscope").setup({
			draw = {
				delay = 0,

				predicate = function(scope)
					return not scope.body.is_incomplete
				end,
				priority = 2,
			},
			mappings = {
				-- Textobjects
				object_scope = "ii",
				object_scope_with_border = "ai",

				-- Motions (jump to respective border line; if not present - body line)
				goto_top = "[i",
				goto_bottom = "]i",
			},

			-- Options which control scope computation
			options = {
				border = "both",
				indent_at_cursor = true,
				n_lines = 10000,
				try_as_border = false,
			},

			-- Which character to use for drawing scope indicator
			symbol = "╎",
		})

		require("mini.cursorword").setup({
			delay = 0,
		})
	end,
})

require("mini.icons").setup({
	style = "glyph",
	file = {
		README = { glyph = "󰆈", hl = "MiniIconsYellow" },
		["README.md"] = { glyph = "󰆈", hl = "MiniIconsYellow" },
	},
	filetype = {
		bash = { glyph = "󱆃", hl = "MiniIconsGreen" },
		sh = { glyph = "󱆃", hl = "MiniIconsGrey" },
		toml = { glyph = "󱄽", hl = "MiniIconsOrange" },
	},
})

local MiniPick = require("mini.pick")
MiniPick.registry.files = function(local_opts, opts)
	local tool = local_opts.tool or "rg"
	if tool == "rg" then
		return MiniPick.builtin.cli({
			command = { "rg", "--files", "--hidden", "--glob", "!.git" }, -- 排除 .git
			postprocess = MiniPick.default_postprocess_files,
		}, opts)
	elseif tool == "fd" then
		return MiniPick.builtin.cli({
			command = { "fd", "--type", "f", "--hidden", "--exclude", ".git" },
			postprocess = MiniPick.default_postprocess_files,
		}, opts)
	else
		-- 其他工具沿用默认逻辑
		return MiniPick.builtin.files(local_opts, opts)
	end
end

require("mini.extra").setup()

local MiniNotify = require("mini.notify")
MiniNotify.setup({
	content = {
		format = nil,
		sort = nil,
	},
	lsp_progress = {
		enable = false,
		level = "WARN",
		duration_last = 1000,
	},
	window = {
		config = {},
		max_width_share = 0.382,
		-- Value of 'winblend' option
		winblend = 25,
	},
})
vim.notify = MiniNotify.make_notify({ ERROR = { duration = 10000 } })

MiniPick.setup(
	-- No need to copy this inside `setup()`. Will be used automatically.
	{
		-- Delays (in ms; should be at least 1)
		delay = {
			-- Delay between forcing asynchronous behavior
			async = 10,

			-- Delay between computation start and visual feedback about it
			busy = 50,
		},

		-- Keys for performing actions. See `:h MiniPick-actions`.
		mappings = {
			caret_left = "<Left>",
			caret_right = "<Right>",
			choose = "<CR>",
			choose_in_split = "<C-s>",
			choose_in_tabpage = "<C-t>",
			choose_in_vsplit = "<C-v>",
			choose_marked = "<M-CR>",
			delete_char = "<BS>",
			delete_char_right = "<Del>",
			delete_left = "<C-u>",
			delete_word = "<C-w>",
			mark = "<C-x>",
			mark_all = "<C-a>",
			move_down = "<C-n>",
			move_start = "<C-g>",
			move_up = "<C-p>",
			paste = "<C-r>",
			refine = "<C-Space>",
			refine_marked = "<M-Space>",
			scroll_down = "<C-f>",
			scroll_left = "<C-h>",
			scroll_right = "<C-l>",
			scroll_up = "<C-b>",
			stop = "<Esc>",
			toggle_info = "<S-Tab>",
			toggle_preview = "<Tab>",
		},

		-- General options
		options = {
			-- Whether to show content from bottom to top
			content_from_bottom = false,

			-- Whether to cache matches (more speed and memory on repeated prompts)
			use_cache = false,
		},

		-- Source definition. See `:h MiniPick-source`.
		source = {
			items = nil,
			name = nil,
			cwd = nil,
			match = nil,
			show = nil,
			preview = nil,
			choose = nil,
			choose_marked = nil,
		},

		-- Window related options
		window = {
			-- Float window config (table or callable returning it)
			config = function()
				local height = math.floor(0.618 * vim.o.lines)
				local width = math.floor(0.618 * vim.o.columns)
				return {
					anchor = "NW",
					height = height,
					width = width,
					row = math.floor(0.6 * (vim.o.lines - height)),
					col = math.floor(0.5 * (vim.o.columns - width)),
				}
			end,

			-- String to use as caret in prompt
			prompt_caret = "▏",

			-- String to use as prefix in prompt
			prompt_prefix = "> ",
		},
	}
)

vim.keymap.set("n", "<leader>sb", ":Pick buffers<CR>", { desc = "Search Buffers" })
vim.keymap.set("n", "<leader>sf", ":Pick files<CR>", { desc = "Search files" })
vim.keymap.set("n", "<leader><leader>", ":Pick files<CR>", { desc = "Search files" })
-- vim.keymap.set("n", "<leader>sg", ":Pick grep pattern='<cword>'<CR>", { desc = "Search grep" })
vim.keymap.set("n", "<leader>sg", ":Pick grep_live<CR>", { desc = "Search grep" })
vim.keymap.set("n", "<leader>sh", ":Pick help<CR>", { desc = "Search help" })
vim.keymap.set("n", "<leader>sH", ":Pick history<CR>", { desc = "Search history" })
vim.keymap.set("n", "<leader>sp", ":Pick registers<CR>", { desc = "Search register" })
vim.keymap.set("n", "<leader>sD", ":Pick diagnostic<CR>", { desc = "Search diagnostic" })
vim.keymap.set("n", "<leader>sm", ":Pick marks<CR>", { desc = "Search marks" })
vim.keymap.set("n", "<leader>sc", ":Pick commands<CR>", { desc = "Search commands" })
vim.keymap.set("n", "<leader>sk", ":Pick keymaps<CR>", { desc = "Search keymaps" })
vim.keymap.set("n", "<leader>st", ":Pick hipatterns<CR>", { desc = "Search todos" })
vim.keymap.set("n", "<leader>ss", function()
	require("mini.extra").pickers.lsp({ scope = "workspace_symbol_live" })
end, { desc = "Search symbol" })

vim.keymap.set("n", "<leader>sd", function()
	require("mini.extra").pickers.lsp({ scope = "definition" })
end, { desc = "Search definition" })

local function show_notify_history()
	local history = MiniNotify.get_all()
	if not history or #history == 0 then
		return vim.notify("No notify history available", vim.log.levels.WARN)
	end
	local items = {}
	for i = #history, 1, -1 do
		local entry = history[i]
		table.insert(items, string.format("[%s] %s", entry.level, entry.msg))
	end
	-- 启动 mini.pick
	require("mini.pick").start({
		source = {
			items = items,
			name = "Notify History",
			choose = function(item)
				local msg = item:gsub("^%[[A-Z]+%]%s*", "")
				vim.fn.setreg("+", msg)
				vim.notify("Copied to clipboard: " .. msg, vim.log.levels.INFO)
			end,
		},
	})
end
vim.keymap.set("n", "<leader>nl", show_notify_history, { desc = "Show mini.notify history" })
