## Usage

This project is for storing my basic dev configure of bundle of modern tools.

Steps:

- clone this project
- if `homebrew` is used, run `./script/install_tools.sh` to install tools
- run `install.sh` to set configure for each tool,
- run `script/install_font.sh` to install font.

## Theme selector

主题源文件集中在 `themes/`，目前仅保留 `material_deep_ocean` 和 `neofusion`，
目录结构对应 `config/`。例如：

```text
themes/
  ghostty/themes/neofusion.conf
  kitty/themes/neofusion.conf
  tmux/neofusion.conf
  btop/themes/neofusion.theme
  starship/neofusion.toml
  lazygit/neofusion.yml
  lazydocker/neofusion.yml
  zellij/neofusion.kdl
  nvim/lua/plugins/neofusion.lua
  yazi/neofusion.toml
  yazi/neofusion.tmTheme
  server/tmux/neofusion.conf
```

使用 Python 3 标准库，无需安装额外依赖：

```sh
./shell/scripts/theme-selector list
./shell/scripts/theme-selector change neofusion
./shell/scripts/theme-selector change material_deep_ocean
```

安装 shell 配置并重新加载后，也可以直接运行 `theme-selector`。

`list` 每行只显示一个主题名。`change` 把同名源文件复制成
相同目录下的 `theme.<扩展名>`，例如：
`themes/kitty/themes/neofusion.conf` → `config/kitty/themes/theme.conf`。
`themes/server/` 对应 `server/config/`。各软件始终引用固定的活动主题文件。

目前两个主题覆盖相同的软件和配置文件；以后新增主题时，没有对应主题的文件会
保留原样并静默跳过。Neovim 的状态栏、标签栏随选中的主题使用相应配色。
bat/yazi 的语法主题和 yazi 的界面主题是分别复制的文件。

Starship、Lazygit、Lazydocker 和 Zellij 的主配置通过相对软链接指向活动的
`theme.*` 文件，它们的主题源文件包含完整配置；修改提示符布局、快捷键等通用
设置时，需要同步修改两个主题版本。Starship 在下一次绘制提示符时读取新主题；
已经打开的 TUI 软件需要重启。Zed 仍使用自身的主题设置，未接入此切换脚本；
herdr 使用终端配色。

添加主题：在所需软件的对应目录下添加 `<主题名>.<扩展名>`，随后即可使用
`list` 和 `change`，不必修改脚本。主题名使用字母、数字、下划线和连字符，
以字母或数字开头。同一主题在各软件中的名字需要一致。
新增软件时，先让它的主配置引用对应的固定 `theme.*` 文件。

`config/` 和 `server/config/` 下的活动 `theme.*` 已加入 `.gitignore`，
切换只改变本机文件。修改主题时应编辑 `themes/` 中的源文件，再执行 `change`。
新机器执行 `install.sh` 时会初始化缺失的活动主题（优先 Neofusion），保留已有选择，
并从 `config/btop/btop.conf.default` 初始化缺失的 btop 主配置。
单独使用 server 配置前，也需要先运行一次 `theme-selector change neofusion`。

复制完成后，脚本会自动执行 `bat cache --build`（未安装 bat 时跳过）。
其他软件仍需重载或重启；tmux 可运行 `tmux source-file ~/.config/tmux/tmux.conf`。

## Tools

### TUI tools

- `neovim`: use `LazyVim` for basic configure package
- `starship`: terminal prompt
- `tmux`: terminal multiplier, and use `tpm` for plugin management
- `zellij`: a new terminal multiplier write in Rust
- `zsh`: use `zinit` for plugin management
- `lsd`: better `ls` command
- `eza`: another better `ls` command
- `zxoide`: better `cd` command
- `lazygit` and `lazydocker`: tui tool for git and docker
- `btop`: terminal monitor
- `dust`: better `df` command
- `ripgrep`: better `grep` command
- `yazi`: tui file explorer

### Terminal

- `kitty`: terminal emulator
- `ghossty`: terminal emulator

### Input method

`Rime` is the chinese input method, the configuration of Rime is in `./Rime/`
[Download link](https://rime.im/download/)

- For MacOS, use `squirrel`
- For Windows, use `weasel`
- For Linux, use `fcitx5-rime`

### Other

- zed: modern code editor

## issue

### kitty chinese input method

In Debian/Ubuntu, add these lines to `/etc/environment`, then reboot.

x11:

```config
GTK_IM_MODULE=fcitx
QT_IM_MODULE=fcitx
XMODIFIERS=@im=fcitx
SDL_IM_MODULE=fcitx
INPUT_METHOD=fcitx
GLFW_IM_MODULE=ibus

```

wayland:
1. 不要设置 GTK_IM_MODULE 环境变量！

2. 对于 Gtk2，向 ~/.gtkrc-2.0 添加如下内容：

```
gtk-im-module="fcitx"
```

3. 对于 Gtk3，向 ~/.config/gtk-3.0/settings.ini 添加如下内容：

```
[Settings]
gtk-im-module=fcitx
```

4. 对于 Gtk4。向 ~/.config/gtk-4.0/settings.ini 添加如下内容：
```
[Settings]
gtk-im-module=fcitx

```
5. 如果你在用 GNOME 3 和以上版本，你还需要运行以下命令：

```
gsettings set org.gnome.settings-daemon.plugins.xsettings overrides "{'Gtk/IMModule':<'fcitx'>}"

```

### Copy to clipboard in Neovim of Linux

- x11: install `xclip`
- wayland: install `wl-clipboard`

### Macos setup mouse

~~~bash
defaults write -g ApplePressAndHoldEnabled -bool false
~~~
