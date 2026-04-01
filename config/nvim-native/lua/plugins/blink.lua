-- blink.cmp 安装补全配置以及触发加载
vim.pack.add({
	{ src = "https://github.com/saghen/blink.cmp", version = vim.version.range("1.*") },
}, {
	load = function(plug_data)
		-- 不执行任何操作，完全不加载插件
		-- 只在 InsertEnter 时手动添加到 runtimepath 并加载
		vim.api.nvim_create_autocmd("InsertEnter", {
			once = true,
			callback = function()
				-- 手动添加到 runtimepath
				vim.opt.runtimepath:append(plug_data.path)
				-- 加载 plugin 文件
				require("blink.cmp").setup({
					keymap = { preset = "super-tab" },
					sources = {
						default = { "lsp", "path", "snippets", "buffer" },
					},
				})
			end,
		})
	end,
})
