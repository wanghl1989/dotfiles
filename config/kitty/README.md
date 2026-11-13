# 垂直 tab 栏

当前配置面向 kitty 0.50.0：左侧标签标题保持原位，选中背景以 180 ms
缓动上下滑动，默认圆角；不再显示 `▌` 和 `>`。修改后用 `⌘Q` 完全退出
kitty，再重新打开；只关闭窗口不会退出 macOS 上的 kitty 后台进程。

调节外观：

- 圆角：修改 [shaders/vertical-tab-slide.pipeline](shaders/vertical-tab-slide.pipeline)
  中的 `CORNER_RADIUS`。按单行高度计算；`0` 为直角，`0.5` 接近胶囊形。
- 左侧留白：同一文件中的 `LEFT_PADDING`，默认 `0.25`，表示标签背景从左边缘
  缩进四分之一行高；数值越大，空隙越宽。标题位置不变。
- 动画时长：修改 [tab_bar.py](tab_bar.py) 的 `SLIDE_SECONDS`，单位为秒。
- 颜色：沿用主题的 `active_tab_background`、`active_tab_foreground` 和
  `inactive_tab_foreground`，无需在 shader 里再维护一份颜色。
- 关闭动画和圆角：注释 `kitty.conf` 中的 `custom_shaders vertical-tab-slide`，
  重启后使用普通选中背景。

鼠标点击、拖动和标题排布继续使用 kitty 原生布局。标签太多时，空行间隔按原生
规则压缩；动画读取实际位置。改变窗口、字体或标签数量时直接对齐到新布局。
快速连续切换从当前动画位置继续，不会先跳回上一行。

当前动画支持左侧、单行标题。侧栏不足 5 行、极端尺寸（视口任一边达到 8192
物理像素）、多行标题或改到右侧时，回退到普通背景。
shader 尚未加载或编译失败时也保留普通选中背景，不写入内部颜色数据。

实现使用 Python 将几何和主题颜色写入保留的空白列，再由 Slang shader 读取、
擦除并绘制圆角背景。其思路参考
[kitty-sliding-tabs](https://github.com/patricorgi/kitty-sliding-tabs)，垂直布局和数据协议另行实现。

验证使用 kitty 自己的 `Screen`、垂直布局和命中测试，无需启动 GUI：

```sh
kitty +runpy 'import runpy; runpy.run_path("/absolute/path/to/dotfiles/config/kitty/tests/test_tab_bar.py", run_name="__main__")'
```

完整 shader 管线回归（macOS，无需 GUI）使用 kitty 自己的编译、纹理采样和
透明度包装，检查主题、透明/不透明背景、圆角、动画中间帧及用户截图中的几何：

```sh
python3 config/kitty/tests/test_shader_macos.py
```

`fragment_main` 的颜色输入和返回值为非预乘颜色，纹理样本为预乘颜色；测试必须
经过 kitty 的包装层，不能直接把纹理像素传入 `fragment_main`。
接口和管线说明见 [kitty 官方文档](https://sw.kovidgoyal.net/kitty/custom-shaders/)。
