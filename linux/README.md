# Linux Niri 窗口管理器配置

Niri 无线平铺窗口管理器, 文件夹中保存了所用到的工具的配置, 基于wayland

- 程序启动器: 程序启动使用的是自带的`fuzzel`

- 剪贴板: 终端命令工具`wl-copy`, 剪贴板历史工具为`clipse`和`clipse-gui`

- 锁屏和壁纸: 锁屏使用的是`swaylock`, 壁纸采用`swaylock`

- 截图： 默认的gnome截图工具和niri的截图工具`satty`

- 状态栏: `waybar`

## Niri 显示器设置

在niri文件夹中创建monitor.kdl文件, 写入显示器配置，参考配置如下

```kdl

// Outputs from existing configuration
output "HDMI-0" {
    // 取消注释以禁用此显示器。
    // off

    // 默认聚焦在这个显示器
    focus-at-startup

    // 格式为"<width>x<height>" 或者 "<width>x<height>@<refresh rate>".
    // 如果省略了刷新率，niri将为分辨率选择最高的刷新率。
    mode "3840x2160@60.000"

    // 您可以使用整数或分数量表，例如，比例为150％。
    scale 1.5

    // transform允许逆时针旋转显示，有效值为:
    // normal, 90, 180, 270, flipped, flipped-90, flipped-180 and flipped-270.
    transform "normal"

    // 输出在所有显示器坐标空间中的位置。未明确配置位置的显示器将放置在所有已放置的显示器右侧。
    // position x=1280 y=0
}
```

在ubuntu中升级后无法使用微信等程序，还是有bug，可能需要25.10后的版本
