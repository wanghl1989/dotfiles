local M = {}

local ui_buf
local ui_win
local current_plugin_map = {}
local highlight_ns = vim.api.nvim_create_namespace("pack_ui")
local window_group = vim.api.nvim_create_augroup("PackUIWindow", { clear = true })
local MAX_CONCURRENT_FETCHES = 4
local plugin_states = {}
local update_job

local function notify(message, level)
	vim.notify(message, level or vim.log.levels.INFO, { title = "Pack Manager" })
end

local function get_plugin_list()
	-- The UI does not display branch/tag information, so avoid running Git
	-- commands for every plugin whenever the window is rendered.
	local plugins = vim.pack.get(nil, { info = false })
	table.sort(plugins, function(a, b)
		return a.spec.name:lower() < b.spec.name:lower()
	end)
	return plugins
end

local function get_window_layout()
	local available_width = math.max(vim.o.columns - 2, 1)
	local available_height = math.max(vim.o.lines - vim.o.cmdheight - 2, 1)
	local width = math.max(1, math.min(math.floor(vim.o.columns * 0.8), available_width))
	local height = math.max(1, math.min(math.floor(vim.o.lines * 0.8), available_height))

	return {
		relative = "editor",
		width = width,
		height = height,
		row = math.max(0, math.floor((available_height - height) / 2)),
		col = math.max(0, math.floor((vim.o.columns - width) / 2)),
	}
end

local function create_floating_window()
	local buf = vim.api.nvim_create_buf(false, true)
	local layout = get_window_layout()
	local win = vim.api.nvim_open_win(buf, true, {
		relative = layout.relative,
		width = layout.width,
		height = layout.height,
		row = layout.row,
		col = layout.col,
		style = "minimal",
		border = "rounded",
		title = " 󰏗 Plugin Manager (vim.pack) ",
		title_pos = "center",
	})

	vim.bo[buf].bufhidden = "wipe"
	vim.bo[buf].filetype = "pack_ui"
	vim.bo[buf].modifiable = false
	vim.wo[win].cursorline = true
	vim.wo[win].wrap = false

	return buf, win
end

local function truncate(text, max_width)
	text = tostring(text or "")
	if max_width <= 0 then
		return ""
	end
	if vim.fn.strdisplaywidth(text) <= max_width then
		return text
	end
	if max_width == 1 then
		return "…"
	end

	local result = {}
	local width = 0
	for index = 0, vim.fn.strchars(text) - 1 do
		local char = vim.fn.strcharpart(text, index, 1)
		local char_width = vim.fn.strdisplaywidth(char)
		if width + char_width + 1 > max_width then
			break
		end
		result[#result + 1] = char
		width = width + char_width
	end

	return table.concat(result) .. "…"
end

local function pad_right(text, width)
	text = truncate(text, width)
	return text .. string.rep(" ", math.max(0, width - vim.fn.strdisplaywidth(text)))
end

local function add_token_highlights(buf, row, line, token, group)
	local start = 1
	while true do
		local first, last = line:find(token, start, true)
		if not first then
			return
		end
		vim.api.nvim_buf_add_highlight(buf, highlight_ns, group, row, first - 1, last)
		start = last + 1
	end
end

local function set_highlights(buf)
	vim.api.nvim_buf_clear_namespace(buf, highlight_ns, 0, -1)
	for index, line in ipairs(vim.api.nvim_buf_get_lines(buf, 0, -1, false)) do
		local row = index - 1
		add_token_highlights(buf, row, line, "󰄬", "DiagnosticOk")
		add_token_highlights(buf, row, line, "○", "DiagnosticWarn")
		add_token_highlights(buf, row, line, "󰑓", "DiagnosticHint")
		add_token_highlights(buf, row, line, "󰇚", "DiagnosticInfo")
		add_token_highlights(buf, row, line, "󱑮", "DiagnosticInfo")
		add_token_highlights(buf, row, line, "󰅖", "DiagnosticError")
		if index == 1 then
			vim.api.nvim_buf_add_highlight(buf, highlight_ns, "Title", row, 0, -1)
		end
	end
end

function M.render()
	if not ui_buf or not vim.api.nvim_buf_is_valid(ui_buf) then
		return
	end

	local win_width = 80
	if ui_win and vim.api.nvim_win_is_valid(ui_win) then
		win_width = vim.api.nvim_win_get_width(ui_win)
	end

	local plugins = get_plugin_list()
	local task_line = ""
	if update_job then
		if update_job.phase == "fetching" then
			task_line = ("  Fetching: %d/%d finished, %d running, %d queued"):format(
				update_job.finished,
				update_job.total,
				update_job.active,
				#update_job.queue
			)
		elseif update_job.phase == "applying" then
			task_line = ("  Applying: %d plugin(s) with vim.pack"):format(#update_job.successful)
		elseif update_job.phase == "done" then
			task_line = ("  Last update: %d processed, %d fetch error(s)"):format(
				#update_job.successful,
				update_job.failed
			)
		end
	end

	local lines = {
		string.format("  Total: %d plugins managed by vim.pack", #plugins),
		truncate(
			"  Status: 󰄬 Loaded  ○ Not loaded  󰑓 Queued  󰇚 Fetching  󱑮 Applying  󰅖 Error",
			win_width
		),
		truncate(task_line, win_width),
		"  " .. string.rep("─", math.max(1, win_width - 4)),
		"",
	}
	local new_plugin_map = {}
	local show_revision = win_width >= 45
	local usable_width = math.max(1, win_width - 6)
	local name_width = math.max(1, math.min(30, math.floor(usable_width * 0.35)))

	for _, plugin in ipairs(plugins) do
		local state = plugin_states[plugin.spec.name]
		local icon = plugin.active and "󰄬" or "○"
		if state == "queued" then
			icon = "󰑓"
		elseif state == "fetching" then
			icon = "󰇚"
		elseif state == "applying" then
			icon = "󱑮"
		elseif state == "error" then
			icon = "󰅖"
		end
		local prefix = "  " .. icon .. " " .. pad_right(plugin.spec.name, name_width) .. " "
		if show_revision then
			prefix = prefix .. pad_right((plugin.rev or "--------"):sub(1, 8), 8) .. " "
		end
		local source_width = math.max(0, win_width - vim.fn.strdisplaywidth(prefix) - 2)
		lines[#lines + 1] = prefix .. truncate(plugin.spec.src, source_width)
		new_plugin_map[#lines] = plugin
	end

	lines[#lines + 1] = ""
	lines[#lines + 1] = "  " .. string.rep("─", math.max(1, win_width - 4))
	lines[#lines + 1] = truncate(
		"  (u) async update  (U) async update all  (x) delete inactive  (X) clean inactive  (r) refresh  (q) close  (?) help",
		win_width
	)

	local cursor_row = 1
	if ui_win and vim.api.nvim_win_is_valid(ui_win) then
		cursor_row = vim.api.nvim_win_get_cursor(ui_win)[1]
	end

	vim.api.nvim_set_option_value("modifiable", true, { buf = ui_buf })
	vim.api.nvim_buf_set_lines(ui_buf, 0, -1, false, lines)
	vim.api.nvim_set_option_value("modifiable", false, { buf = ui_buf })
	set_highlights(ui_buf)
	current_plugin_map = new_plugin_map

	if ui_win and vim.api.nvim_win_is_valid(ui_win) then
		vim.api.nvim_win_set_cursor(ui_win, { math.min(cursor_row, #lines), 0 })
	end
end

local refresh_group = vim.api.nvim_create_augroup("PackUIRefresh", { clear = true })
vim.api.nvim_create_autocmd("PackChanged", {
	group = refresh_group,
	callback = function()
		vim.schedule(M.render)
	end,
})

local function plugin_under_cursor(win)
	if not vim.api.nvim_win_is_valid(win) then
		return
	end
	return current_plugin_map[vim.api.nvim_win_get_cursor(win)[1]]
end

local function update_is_running()
	return update_job and update_job.phase ~= "done"
end

local function run_update(names)
	if update_is_running() then
		notify("An update job is already running", vim.log.levels.WARN)
		return
	end

	local requested = names
			and vim.iter(names):fold({}, function(result, name)
				result[name] = true
				return result
			end)
		or nil
	local items = vim.iter(get_plugin_list())
		:filter(function(plugin)
			return not requested or requested[plugin.spec.name]
		end)
		:map(function(plugin)
			return { name = plugin.spec.name, path = plugin.path }
		end)
		:totable()

	if #items == 0 then
		notify("Nothing to update", vim.log.levels.WARN)
		return
	end

	plugin_states = {}
	update_job = {
		phase = "fetching",
		queue = items,
		active = 0,
		finished = 0,
		total = #items,
		successful = {},
		failed = 0,
	}
	local job = update_job
	for _, item in ipairs(items) do
		plugin_states[item.name] = "queued"
	end
	M.render()

	local start_next_fetch
	local function apply_updates()
		if #job.successful == 0 then
			job.phase = "done"
			M.render()
			notify("Update stopped: every fetch failed", vim.log.levels.ERROR)
			return
		end

		job.phase = "applying"
		for _, name in ipairs(job.successful) do
			plugin_states[name] = "applying"
		end
		M.render()

		-- Yield once so the applying state is painted before vim.pack enters its
		-- event-processing wait. All checkouts and the lockfile write happen in
		-- this single official update call.
		vim.schedule(function()
			local ok, err = pcall(vim.pack.update, job.successful, { force = true, offline = true })
			if ok then
				for _, name in ipairs(job.successful) do
					plugin_states[name] = nil
				end
			else
				for _, name in ipairs(job.successful) do
					plugin_states[name] = "error"
				end
				notify("Applying updates failed:\n" .. tostring(err), vim.log.levels.ERROR)
			end
			job.phase = "done"
			M.render()
			if ok then
				notify(
					("Update job finished: %d processed, %d fetch error(s)"):format(#job.successful, job.failed),
					job.failed > 0 and vim.log.levels.WARN or vim.log.levels.INFO
				)
			end
		end)
	end

	start_next_fetch = function()
		local item = table.remove(job.queue, 1)
		if not item then
			return
		end

		job.active = job.active + 1
		plugin_states[item.name] = "fetching"
		vim.system(
			{ "git", "fetch", "--quiet", "--tags", "--force", "--recurse-submodules=yes", "origin" },
			{ cwd = item.path, text = true },
			function(result)
				vim.schedule(function()
					job.active = job.active - 1
					job.finished = job.finished + 1
					if result.code == 0 then
						job.successful[#job.successful + 1] = item.name
						plugin_states[item.name] = "queued"
					else
						job.failed = job.failed + 1
						plugin_states[item.name] = "error"
					end

					if job.finished == job.total then
						apply_updates()
					else
						start_next_fetch()
						M.render()
					end
				end)
			end
		)
	end

	for _ = 1, math.min(MAX_CONCURRENT_FETCHES, job.total) do
		start_next_fetch()
	end
	if job.total > 0 then
		M.render()
	end
end

local function delete_plugins(names)
	local ok, err = pcall(vim.pack.del, names)
	if not ok then
		notify("Delete failed:\n" .. tostring(err), vim.log.levels.ERROR)
		return
	end
	M.render()
end

local function confirm_delete(names, prompt)
	vim.ui.select({ "No", "Yes" }, { prompt = prompt }, function(choice)
		if choice == "Yes" then
			delete_plugins(names)
		end
	end)
end

function M.show()
	if ui_win and vim.api.nvim_win_is_valid(ui_win) then
		vim.api.nvim_set_current_win(ui_win)
		return
	end
	if ui_buf and vim.api.nvim_buf_is_valid(ui_buf) then
		vim.api.nvim_buf_delete(ui_buf, { force = true })
	end

	ui_buf, ui_win = create_floating_window()
	local buf = ui_buf
	local win = ui_win

	vim.api.nvim_clear_autocmds({ group = window_group })
	vim.api.nvim_create_autocmd("VimResized", {
		group = window_group,
		callback = function()
			if not vim.api.nvim_win_is_valid(win) then
				return
			end
			vim.api.nvim_win_set_config(win, get_window_layout())
			M.render()
		end,
	})
	vim.api.nvim_create_autocmd("BufWipeout", {
		group = window_group,
		buffer = buf,
		once = true,
		callback = function()
			if ui_buf == buf then
				ui_buf = nil
				ui_win = nil
				current_plugin_map = {}
			end
		end,
	})

	local function close()
		if vim.api.nvim_win_is_valid(win) then
			vim.api.nvim_win_close(win, true)
		end
	end

	local function map(lhs, rhs, desc)
		vim.keymap.set("n", lhs, rhs, { buffer = buf, silent = true, desc = desc })
	end

	map("q", close, "Close plugin manager")
	map("<Esc>", close, "Close plugin manager")
	map("r", M.render, "Refresh plugin list")
	map("u", function()
		local plugin = plugin_under_cursor(win)
		if not plugin then
			notify("No plugin under cursor", vim.log.levels.WARN)
			return
		end
		run_update({ plugin.spec.name })
	end, "Update plugin asynchronously")
	map("U", function()
		run_update(nil)
	end, "Update all plugins asynchronously")
	map("x", function()
		if update_is_running() then
			notify("Wait for the update job before deleting plugins", vim.log.levels.WARN)
			return
		end
		local plugin = plugin_under_cursor(win)
		if not plugin then
			notify("No plugin under cursor", vim.log.levels.WARN)
			return
		end
		if plugin.active then
			notify(
				("%s is loaded. Remove its vim.pack.add() entry, restart Neovim, then clean inactive plugins."):format(
					plugin.spec.name
				),
				vim.log.levels.WARN
			)
			return
		end
		confirm_delete({ plugin.spec.name }, "Delete inactive plugin " .. plugin.spec.name .. "?")
	end, "Delete inactive plugin")
	map("X", function()
		if update_is_running() then
			notify("Wait for the update job before cleaning plugins", vim.log.levels.WARN)
			return
		end
		local inactive = vim.iter(get_plugin_list())
			:filter(function(plugin)
				return not plugin.active
			end)
			:map(function(plugin)
				return plugin.spec.name
			end)
			:totable()
		if #inactive == 0 then
			notify("No inactive plugins to clean")
			return
		end
		confirm_delete(inactive, ("Delete %d inactive plugin(s): %s?"):format(#inactive, table.concat(inactive, ", ")))
	end, "Clean all inactive plugins")
	map("?", function()
		notify(table.concat({
			"u: Update plugin under cursor asynchronously",
			"U: Update all plugins asynchronously",
			"x: Delete plugin under cursor when it is inactive",
			"X: Delete all inactive plugins",
			"r: Refresh plugin list",
			"q / Esc: Close",
		}, "\n"))
	end, "Show plugin manager help")

	M.render()
end

return M
