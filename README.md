## Usage

This project is for storing my basic dev configure of bundle of modern tools.

Steps:

- clone this project
- if `homebrew` is used, run `./script/install_tools.sh` to install tools
- run `install.sh` to set configure for each tool,
- run `script/install_font.sh` to install font.

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
