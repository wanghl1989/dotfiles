local M = {}

local updating_plugins = {}
local ui_buf = nil
local ui_win = nil
local current_plugin_map = {}

-- Task Queue for Concurrency Control
local task_queue = {}
local active_tasks = 0
local MAX_CONCURRENT = 4

local function get_plugin_list()
	local plugins = vim.pack.get()
	table.sort(plugins, function(a, b)
		return a.spec.name:lower() < b.spec.name:lower()
	end)
	return plugins
end

local function create_floating_window()
	local width = math.floor(vim.o.columns * 0.8)
	local height = math.floor(vim.o.lines * 0.8)
	local row = math.floor((vim.o.lines - height) / 2)
	local col = math.floor((vim.o.columns - width) / 2)

	local buf = vim.api.nvim_create_buf(false, true)
	local win = vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		width = width,
		height = height,
		row = row,
		col = col,
		style = "minimal",
		border = "rounded",
		title = " 󰏗 Plugin Manager (vim.pack) ",
		title_pos = "center",
	})

	return buf, win
end

local function set_highlights(buf)
	local ns = vim.api.nvim_create_namespace("pack_ui")
	vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)

	local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
	for i, line in ipairs(lines) do
		if line:match("󰄬") then
			vim.api.nvim_buf_add_highlight(buf, ns, "DiagnosticOk", i - 1, line:find("󰄬") - 1, line:find("󰄬") + 3)
		elseif line:match("○") then
			vim.api.nvim_buf_add_highlight(buf, ns, "DiagnosticWarn", i - 1, line:find("○") - 1, line:find("○") + 3)
		elseif line:match("󱑮") then
			vim.api.nvim_buf_add_highlight(buf, ns, "DiagnosticInfo", i - 1, line:find("󱑮") - 1, line:find("󱑮") + 3)
		end

		if i == 1 then
			vim.api.nvim_buf_add_highlight(buf, ns, "Title", i - 1, 0, -1)
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
	local lines = {}
	local new_plugin_map = {}

	table.insert(lines, string.format("  Total: %d plugins managed by vim.pack", #plugins))
	table.insert(lines, "  Status: 󰄬 Active  ○ Inactive  󱑮 Updating")
    if active_tasks > 0 or #task_queue > 0 then
        table.insert(lines, string.format("  Tasks: %d active, %d queued", active_tasks, #task_queue))
    else
        table.insert(lines, "")
    end
	table.insert(lines, "")
    table.insert(lines, "  " .. string.rep("─", win_width - 4))
    table.insert(lines, "")

	for i, p in ipairs(plugins) do
		local icon = p.active and "󰄬" or "○"
        if updating_plugins[p.spec.name] then
            icon = "󱑮"
        end
		local line = string.format("  %s %-30s %s", icon, p.spec.name, p.spec.src)
		table.insert(lines, line)
		new_plugin_map[#lines] = p
	end

    table.insert(lines, "")
    table.insert(lines, "  " .. string.rep("─", win_width - 4))
    table.insert(lines, "  (u) update  (U) update all  (x) delete  (X) clean  (q) close  (?) help")

	vim.api.nvim_set_option_value("modifiable", true, { buf = ui_buf })
	vim.api.nvim_buf_set_lines(ui_buf, 0, -1, false, lines)
	vim.api.nvim_set_option_value("modifiable", false, { buf = ui_buf })
    
    set_highlights(ui_buf)
    current_plugin_map = new_plugin_map
end

local function process_queue()
    if #task_queue == 0 or active_tasks >= MAX_CONCURRENT then
        return
    end

    local name = table.remove(task_queue, 1)
    local info = vim.pack.get({ name })[1]
    
    if not info then
        process_queue()
        return
    end

    active_tasks = active_tasks + 1
    updating_plugins[name] = true
    vim.schedule(function() M.render() end)

    vim.system({ "git", "fetch", "--quiet", "--all" }, { cwd = info.path }, function()
        vim.schedule(function()
            pcall(function()
                vim.pack.update({ name }, { force = true, offline = true })
            end)
            
            updating_plugins[name] = nil
            active_tasks = active_tasks - 1
            M.render()
            process_queue() -- Process next in queue

            if active_tasks == 0 and #task_queue == 0 then
                vim.notify("All plugin updates finished", vim.log.levels.INFO, { title = "Pack Manager" })
            end
        end)
    end)
    
    -- Start another one if we have capacity
    process_queue()
end

local function run_async_update(plugin_names)
    for _, name in ipairs(plugin_names) do
        local already_in_queue = false
        for _, qname in ipairs(task_queue) do
            if qname == name then already_in_queue = true break end
        end
        
        if not updating_plugins[name] and not already_in_queue then
            table.insert(task_queue, name)
        end
    end
    process_queue()
end

function M.show()
    -- If already open, just focus it
    if ui_win and vim.api.nvim_win_is_valid(ui_win) then
        vim.api.nvim_set_current_win(ui_win)
        return
    end

	ui_buf, ui_win = create_floating_window()
	M.render()

	vim.api.nvim_set_option_value("filetype", "pack_ui", { buf = ui_buf })

	-- Keybindings
	local opts = { noremap = true, silent = true, buffer = ui_buf }
	
	-- Close
	vim.keymap.set("n", "q", ":close<CR>", opts)
	vim.keymap.set("n", "<ESC>", ":close<CR>", opts)

	-- Update current
	vim.keymap.set("n", "u", function()
		local row = vim.api.nvim_win_get_cursor(ui_win)[1]
		local p = current_plugin_map[row]
		if p then
            run_async_update({ p.spec.name })
		end
	end, opts)

	-- Update all
	vim.keymap.set("n", "U", function()
        local plugins = get_plugin_list()
        local names = {}
        for _, p in ipairs(plugins) do
            table.insert(names, p.spec.name)
        end
        run_async_update(names)
	end, opts)

	-- Delete (simplified confirm to avoid modal)
	vim.keymap.set("n", "x", function()
		local row = vim.api.nvim_win_get_cursor(ui_win)[1]
		local p = current_plugin_map[row]
		if p then
            vim.ui.select({"No", "Yes"}, {
                prompt = "Delete plugin " .. p.spec.name .. "?",
            }, function(choice)
                if choice == "Yes" then
                    vim.pack.del({ p.spec.name })
                    M.render()
                end
            end)
		end
	end, opts)

    -- Clean
    vim.keymap.set("n", "X", function()
        vim.ui.select({"No", "Yes"}, {
            prompt = "Clean unused plugins?",
        }, function(choice)
            if choice == "Yes" then
                vim.pack.update({}, { offline = true, force = true })
                vim.notify("Cleanup finished", vim.log.levels.INFO)
                M.render()
            end
        end)
    end, opts)

    -- Help
    vim.keymap.set("n", "?", function()
        vim.notify("u: Update current\nU: Update all\nx: Delete current\nX: Clean unused\nq: Close", vim.log.levels.INFO, { title = "Pack UI Help" })
    end, opts)
end

return M
