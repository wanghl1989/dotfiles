## Usage

this project is for storing my basic dev configure of bundle of modern tools.

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

- For macos, use `squirrel`
- For windows, use `weasel`
- For linux, use `fcitx5-rime`

### Other

- zed: modern code editor

## issue

### kitty无法输入中文

在debian系统上，在`/etc/environment`中加入以下设置, 并重启电脑

```config
GTK_IM_MODULE=fcitx
QT_IM_MODULE=fcitx
XMODIFIERS=@im=fcitx
SDL_IM_MODULE=fcitx
INPUT_METHOD=fcitx
GLFW_IM_MODULE=ibus
# Wayland专属关键配置
XDG_CURRENT_DESKTOP=GNOME
GTK_USE_PORTAL=1
```
