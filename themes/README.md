# 添加和维护主题

这里保存各软件的主题源文件。目前提供以下主题，均覆盖下表列出的所有配置路径：

- `material_deep_ocean`
- `neofusion`
- `solarized_osaka`：来自 [Solarized Osaka](https://github.com/craftzdog/solarized-osaka.nvim)。
- `oasis_mirage`：来自 [Oasis 的 Mirage (Dark)](https://github.com/uhs-robert/oasis.nvim)，固定使用暗色版本。

新增两套主题的其他软件配色按上游调色板适配，保留本仓库现有配置布局。
Neovim 在首次加载时通过 `vim.pack.add` 安装对应插件，需要网络连接。

切换脚本会把选中的源文件复制到固定的 `theme.<扩展名>`，软件配置始终读取这个固定文件。

## 快速添加一个主题

以下命令在仓库根目录执行。以给 Kitty 添加 `my_theme` 为例：

```sh
cp themes/kitty/themes/neofusion.conf themes/kitty/themes/my_theme.conf
# 编辑 themes/kitty/themes/my_theme.conf，替换配色
./shell/scripts/theme-selector list
./shell/scripts/theme-selector change my_theme
```

不需要修改脚本或注册主题。只要添加一个主题文件，`list` 就会显示它的名字。
需要支持更多软件时，在对应目录中继续添加同名文件即可。

- 名字只能包含字母、数字、下划线和连字符，且以字母或数字开头，例如 `my_theme`。
- 同一个主题在不同软件中的文件名必须一致，仅扩展名不同。
- 可以只适配部分软件；切换时，没有同名源文件的软件会保留当前配置，并静默跳过。
- 脚本仅复制文件，不会合并配置，也不会替换文件内容中的主题名称或路径。

## 目录和目标文件

`themes/` 的目录结构对应 `config/`，其中 `themes/server/` 对应 `server/config/`。
脚本保留目录和最后一个扩展名，把文件名改成 `theme`。

下表中的 `<name>` 替换成你的主题名：

| 源文件（相对 `themes/`） | 生成的活动文件（相对仓库根目录） |
| --- | --- |
| `alacritty/themes/<name>.toml` | `config/alacritty/themes/theme.toml` |
| `bat/themes/<name>.tmTheme` | `config/bat/themes/theme.tmTheme` |
| `btop/themes/<name>.theme` | `config/btop/themes/theme.theme` |
| `eza/<name>.yml` | `config/eza/theme.yml` |
| `ghostty/themes/<name>.conf` | `config/ghostty/themes/theme.conf` |
| `kitty/themes/<name>.conf` | `config/kitty/themes/theme.conf` |
| `lazydocker/<name>.yml` | `config/lazydocker/theme.yml` |
| `lazygit/<name>.yml` | `config/lazygit/theme.yml` |
| `nvim/lua/plugins/<name>.lua` | `config/nvim/lua/plugins/theme.lua` |
| `server/tmux/<name>.conf` | `server/config/tmux/theme.conf` |
| `starship/<name>.toml` | `config/starship/theme.toml` |
| `tmux/<name>.conf` | `config/tmux/theme.conf` |
| `yazi/<name>.tmTheme` | `config/yazi/theme.tmTheme` |
| `yazi/<name>.toml` | `config/yazi/theme.toml` |
| `zellij/<name>.kdl` | `config/zellij/theme.kdl` |

Yazi 的界面主题（`.toml`）和语法主题（`.tmTheme`）是两个独立文件，需要分别准备。
Bat 的主题文件也使用 `.tmTheme`，注意扩展名大小写。

Starship、Lazygit、Lazydocker 和 Zellij 的源文件包含完整配置，其入口通过符号链接指向
生成的活动文件。添加主题时应复制现有版本，再修改配色，保留提示符布局、快捷键等设置。
修改这些通用设置时，也需要同步维护各个主题版本。

## Neovim 主题约定

建议从 `nvim/lua/plugins/neofusion.lua` 或 `material_deep_ocean.lua` 复制一份开始修改。
这些文件是直接执行的 Lua 模块，不是 Lazy 插件声明表。一个主题文件需要完成以下工作：

1. 用 `vim.pack.add` 加载所需主题插件，调用插件的设置方法并应用 `vim.cmd.colorscheme(...)`。
2. 设置共享界面调色板，供 bufferline、treesitter 和 lualine 的自定义组件使用。
3. 在文件末尾返回 lualine 配色表。

共享调色板需要提供以下字段，具体颜色由新主题决定：

```lua
require("config.appearance").set({
    background = "#0F111A",
    surface = "#1A1C25",
    muted = "#717CB4",
    foreground = "#EEFFFF",
    accent = "#84FFFF",
    error = "#F07178",
})
```

如果主题插件提供 lualine 配色，可以像现有主题一样加载它，再返回副本。
例如 Material 的主题文件在应用配色后执行：

```lua
local lualine_theme = vim.deepcopy(require("lualine.themes.material"))
for _, mode in pairs(lualine_theme) do
    for _, section in ipairs({ "b", "c" }) do
        if mode[section] then
            mode[section].bg = "NONE"
        end
    end
end

return lualine_theme
```

添加其他主题时，把 `lualine.themes.material` 换成该插件实际提供的模块，或自行构造
lualine 配色表。保留上述循环可延续当前 B/C（及对应 X/Y）区域的透明效果。
返回值应是包含 `normal`、`insert`、`visual` 等模式配色的表，不能返回插件声明或 `nil`。

这样 `config/nvim/lua/plugins/lualine.lua` 无需随主题修改，始终使用：

```lua
theme = require("plugins.theme"),
```

`plugins` 是实际目录名。切换后重启 Neovim，以重新加载模块及主题插件。

## 切换与检查

```sh
./shell/scripts/theme-selector list
./shell/scripts/theme-selector change my_theme
git status --short
```

`list` 只输出主题名称。`change` 会输出实际复制的文件；如果安装了 `bat`，复制完成后会
自动执行 `bat cache --build`。若缓存重建失败，主题文件已经复制，可以修复后单独重跑该命令。

切换后重载或重启对应软件。Starship 会在下一次绘制提示符时读取配置。
检查各软件的显示效果，确认源文件中引用的插件、主题名和额外资源都存在。

活动文件 `config/**/theme.*` 和 `server/config/**/theme.*` 已被 Git 忽略。
应编辑并提交 `themes/` 中的源文件；直接修改活动文件会在下次切换时被覆盖。
主题目录中的 `.md` 文档和名称以 `.` 开头的文件不会参与切换。
不要把备份或其他非主题文件放进主题目录，脚本会把其余文件当作主题源文件扫描。

## 新增软件

1. 按软件在 `config/` 下的配置路径，在 `themes/` 下建立对应目录并添加主题文件。
2. 让软件主配置读取固定的 `theme.<扩展名>` 文件；不支持拆分配置的软件，可以参照
   Starship 等现有配置，用完整主题配置配合符号链接接入。
3. 运行 `change` 生成活动文件，并确认软件能正确读取。

切换脚本会自动发现新目录，但不会自动修改软件入口配置或安装配置链接。
Zed 目前使用自身的主题设置，尚未接入此脚本。
