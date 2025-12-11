## Usage

this project is for storing my basic dev config of bundle of mordern tools

steps:

1. clone this project
2. run `script/install_tools.sh` to install `homebrew`, and several tools i use.
3. run `install.sh` only set configs,

script only test in Macos and Ubuntu,

## tools

- neovim: use LazyVim for basic configure package
- starship: terminal prompt
- tmux: use `tpm` for plugin management
- zsh: use `zinit` for plugin management
- lsd: better `ls` command
- zxoide: better `cd` command
- lazygit and lazydocker: tui tool for git and docker
- btop: terminal monitor
- dust: better `df` command
- ripgrep: better `grep` command
- yazi: tui file explorer
- Rime: chinese input method
- kitty: terminal emulator
- ghossty: terminal emulator
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
```
