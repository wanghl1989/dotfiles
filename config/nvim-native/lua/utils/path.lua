-- 纯原生 Neovim 路径美化函数 | 对齐 LazyVim pretty_path 效果
local M = {}
M.pretty_path = function(user_opts)
	-- 默认配置（和 LazyVim 完全一致）
	local opts = vim.tbl_deep_extend("force", {
		relative = "cwd", -- 相对路径：cwd(当前目录) / root(项目根目录)
		length = 3, -- 路径最大显示层级
		modified_sign = "", -- 文件修改标记
		readonly_icon = " 󰌾", -- 只读文件图标
		-- 高亮组（lualine 兼容）
		modified_hl = "MatchParen",
		directory_hl = "",
		filename_hl = "Bold",
	}, user_opts or {})

	-- 工具：获取项目根目录（检测 .git, package.json 等标识）
	local function get_project_root()
		local path = vim.fn.expand("%:p:h")
		local root = vim.fs.find({ ".git", ".hg", ".svn", "package.json", "Makefile" }, {
			path = path,
			upward = true,
			type = "directory",
		})[1]
		return root and vim.fs.dirname(root) or vim.fn.getcwd()
	end

	-- 工具：路径规范化（统一分隔符、Windows 小写）
	local function norm(path)
		path = vim.fs.normalize(path)
		return jit.os == "Windows" and path:lower() or path
	end

	return function()
		local full_path = vim.fn.expand("%:p")
		if full_path == "" then
			return ""
		end

		local cwd = norm(vim.fn.getcwd())
		local root = norm(get_project_root())
		local buf_path = norm(full_path)
		local display_path = full_path

		-- 计算相对路径
		if opts.relative == "cwd" and buf_path:sub(1, #cwd) == cwd then
			display_path = full_path:sub(#cwd + 2)
		elseif buf_path:sub(1, #root) == root then
			display_path = full_path:sub(#root + 2)
		end

		-- 分割路径
		local sep = package.config:sub(1, 1)
		local parts = vim.split(display_path, "[\\/]", { trimempty = true })
		if #parts == 0 then
			return vim.fn.expand("%:t")
		end

		-- 路径截断（和 LazyVim 逻辑完全一致）
		if opts.length > 0 and #parts > opts.length then
			parts = { parts[1], "…", unpack(parts, #parts - opts.length + 2, #parts) }
		end

		-- 高亮格式化
		local function hl(text, group)
			return group and string.format("%%#%s#%s%%*", group, text) or text
		end

		-- 处理文件状态：修改 / 只读
		local filename = parts[#parts]
		if vim.bo.modified then
			filename = hl(filename .. opts.modified_sign, opts.modified_hl)
		else
			filename = hl(filename, opts.filename_hl)
		end

		-- 拼接目录部分
		local dir_part = ""
		if #parts > 1 then
			local dirs = table.concat({ unpack(parts, 1, #parts - 1) }, sep)
			dir_part = hl(dirs .. sep, opts.directory_hl)
		end

		-- 只读图标
		local readonly = vim.bo.readonly and hl(opts.readonly_icon, opts.modified_hl) or ""

		return dir_part .. filename .. readonly
	end
end

return M
