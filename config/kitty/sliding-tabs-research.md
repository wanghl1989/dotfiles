# kitty-sliding-tabs 与本机垂直栏的兼容性

调研日期：2026-11-13。项目固定到 [`dd9a95f`](https://github.com/patricorgi/kitty-sliding-tabs/tree/dd9a95fd49576bc8296c55fb7a7814744a1a3e11)，kitty 源码固定到 `v0.50.0`。本文只记录调研，没有安装插件或修改生效配置。

后续已按用户要求实现垂直圆角背景动画，使用和验证情况见 [README](README.md)。以下保留最初对上游项目的兼容性评估。

结论：**可以借用动画思路，但不能直接接入现有左侧栏。** 项目实现的是顶部横向标签栏的圆角选中背景滑动，标题位置始终不动；不是整个标签、终端内容或垂直栏移动。[Python 实现](https://github.com/patricorgi/kitty-sliding-tabs/blob/dd9a95fd49576bc8296c55fb7a7814744a1a3e11/tab_bar.py#L81-L155)、[shader 合成](https://github.com/patricorgi/kitty-sliding-tabs/blob/dd9a95fd49576bc8296c55fb7a7814744a1a3e11/shaders/active-tab-slide-lite.slang#L60-L85)

## 动画如何实现

- 自定义 `draw_tab()` 沿用 kitty 的 separator 绘制；模块加载时替换 `TabBar.layout` 和 `TabBar.update_horizontal`。原生布局先完成，随后读取活动标签的 `tab_extents.x`，得到背景的左右像素边界。[源码](https://github.com/patricorgi/kitty-sliding-tabs/blob/dd9a95fd49576bc8296c55fb7a7814744a1a3e11/tab_bar.py#L17-L108)
- Python 用单调时钟计算 **180 ms、三次 ease-out** 插值；连续切换时从当前插值位置重新出发。每次通过一次性 **10 ms timer** 请求下一轮更新，按 OS window 保存状态。10 ms 是调度请求，不保证实际 100 fps。[源码](https://github.com/patricorgi/kitty-sliding-tabs/blob/dd9a95fd49576bc8296c55fb7a7814744a1a3e11/tab_bar.py#L55-L150)
- Python 把“当前左右边界、目标左右边界”四个整数编码为尾部四个空白单元的背景色；每个值只有 13 bit，要求 `<8192`。Slang shader 从整窗 backbuffer 解码并擦掉这些色块，在像素层绘制圆角背景、恢复文字覆盖率并重新合成文字颜色。空白单元不足时回退瞬切。[编码](https://github.com/patricorgi/kitty-sliding-tabs/blob/dd9a95fd49576bc8296c55fb7a7814744a1a3e11/tab_bar.py#L74-L78)、[载荷与回退](https://github.com/patricorgi/kitty-sliding-tabs/blob/dd9a95fd49576bc8296c55fb7a7814744a1a3e11/tab_bar.py#L124-L140)、[解码](https://github.com/patricorgi/kitty-sliding-tabs/blob/dd9a95fd49576bc8296c55fb7a7814744a1a3e11/shaders/active-tab-slide-lite.slang#L125-L163)
- pipeline 是 `animation_step 0`，因此动画由 Python 重绘驱动，shader 不会自行定时播放。官方定义中 `0` 代表仅内容或事件变化时重绘。[pipeline](https://github.com/patricorgi/kitty-sliding-tabs/blob/dd9a95fd49576bc8296c55fb7a7814744a1a3e11/shaders/active-tab-slide-lite.pipeline)、[官方语义](https://github.com/kovidgoyal/kitty/blob/v0.50.0/docs/custom-shaders.rst#L421-L427)

## 条件与限制

作者只验证 **kitty 0.50.0、Retina Mac、JetBrains Mono**，Linux 未测。这是已测组合，不应写成“0.50.0 是最低版本”：官方 custom shaders 始于 0.49，而该项目还依赖具体 Python 内部接口及 shader API，未提供旧版本兼容保证。[README](https://github.com/patricorgi/kitty-sliding-tabs/blob/dd9a95fd49576bc8296c55fb7a7814744a1a3e11/README.md)、[官方变更记录](https://github.com/kovidgoyal/kitty/blob/v0.50.0/docs/changelog.rst#L629-L632)

几何条件直接写死：左上位置必须 `(12,12)` **物理像素**，`cell_width == ceil(24*cell_height/53)`，栏列数须符合相同边距计算。配套配置用顶部栏、6 pt 边距；6 pt 在作者的 Retina 环境对应 12 px，不是所有显示器上的恒等式。窗口缩放、字体、DPI 或布局不匹配时滑动回退瞬切；静态 shader 仍使用固定几何，不能据此认为任意布局都安全兼容。[几何检查](https://github.com/patricorgi/kitty-sliding-tabs/blob/dd9a95fd49576bc8296c55fb7a7814744a1a3e11/tab_bar.py#L99-L107)、[配套配置](https://github.com/patricorgi/kitty-sliding-tabs/blob/dd9a95fd49576bc8296c55fb7a7814744a1a3e11/sliding-tabs.conf)、[shader 区域](https://github.com/patricorgi/kitty-sliding-tabs/blob/dd9a95fd49576bc8296c55fb7a7814744a1a3e11/shaders/active-tab-slide-lite.slang#L125-L140)、[kitty 边距单位](https://github.com/kovidgoyal/kitty/blob/v0.50.0/kitty/options/definition.py#L2239-L2257)

主题颜色需要同时改配置与 shader 的五个 RGB 常量；shader 通过已知前景/背景恢复文字覆盖率，额外颜色装饰需要重新验证。整窗离屏纹理也有资源成本：3840×2160、RGBA 每通道 16 bit 约 **63.3 MiB/张**，不是动画状态本身的大小，也不是进程总显存。kitty 通常分配 `GL_RGBA16`，不支持时可能降级。[颜色常量](https://github.com/patricorgi/kitty-sliding-tabs/blob/dd9a95fd49576bc8296c55fb7a7814744a1a3e11/shaders/active-tab-slide-lite.slang#L12-L17)、[kitty 纹理分配](https://github.com/kovidgoyal/kitty/blob/v0.50.0/kitty/shaders.c#L1459-L1492)

## 对现有垂直栏的意义

本机已安装 kitty 0.50.0；`~/.config/kitty` 指向本仓库 `config/kitty`。现有 [kitty.conf](kitty.conf) 使用 `tab_bar_edge left`、`tab_bar_style custom`、标题最大长度 14，字体为 **ZedMono Nerd Font Mono 14 pt**，边距为 `tab_bar_margin_width 10.0`、`tab_bar_margin_height 0.0 1.0`，与项目固定的顶部几何不符；[tab_bar.py](tab_bar.py) 保留 kitty 提供的 `cursor.y`，绘制 `▌`、标题及 `>`。直接复制上游 `tab_bar.py` 会覆盖这套绘制，直接 include 配套配置会把栏改到顶部并改写主题和边距。主题选择器中的 material_deep_ocean/neofusion 也不能直接沿用上游 Catppuccin 颜色常量。

上游动画只挂到 `update_horizontal`，`layout()` 也显式跳过 `self.is_vertical`；shader 仅处理中央内容区上方的水平条带。因此仅把配置的 `top` 改成 `left` 不能产生垂直动画。[Python 分支](https://github.com/patricorgi/kitty-sliding-tabs/blob/dd9a95fd49576bc8296c55fb7a7814744a1a3e11/tab_bar.py#L37-L52)、[更新挂钩](https://github.com/patricorgi/kitty-sliding-tabs/blob/dd9a95fd49576bc8296c55fb7a7814744a1a3e11/tab_bar.py#L154-L155)、[shader 区域](https://github.com/patricorgi/kitty-sliding-tabs/blob/dd9a95fd49576bc8296c55fb7a7814744a1a3e11/shaders/active-tab-slide-lite.slang#L125-L140)

若要保留现有外观并增加像素级背景滑动，需要另写适配：

1. 在原生 `update_vertical()` 完成后读取真实 `tab_extents.y`、`window_geometry` 与 `cell_height`，计算上下边界；同时保留现有 `draw_tab()` 和鼠标命中布局。不要用 `index * 2` 猜位置：原生支持可变标签高度，拥挤时还会取消空白间隔。
2. 重写 shader 的左侧区域裁剪、y 轴插值、圆角和载荷位置；传递实际几何，避免复制 12 px/字体比例假设。窄栏未必有四个连续空单元，载荷协议也需重新设计。
3. 处理窗口尺寸/DPI、快速连续切换、标签增删、空白不足以及多窗口定时器；主题和现有透明背景也需实机验证。视觉上可选择滑动现有 `▌` 指示条或整行背景；可复用的是时间插值、按窗口状态和“Python 传几何、shader 画背景”的结构。

这些是基于源码的改造判断，**尚未实现或实测**。尤其不能在自定义 `draw_tab()` 中以 `is_last` 判断“整栏最后一次绘制”：kitty 0.50.0 的垂直路径会先测量再正式绘制，而且每个标签都传 `is_last=True`；测量阶段通过 `extra_data.for_layout` 标识。应在原生垂直更新完成后做动画载荷写入，并保存/恢复游标状态。[官方垂直绘制](https://github.com/kovidgoyal/kitty/blob/v0.50.0/kitty/tab_bar.py#L1163-L1259)
