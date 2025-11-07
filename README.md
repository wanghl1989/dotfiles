## Usage

1. git clone this repo
2. creat soft link to `~/.config/` by using `install.sh`

```shell
sudo chmod +x install.sh
./install.sh
```

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
