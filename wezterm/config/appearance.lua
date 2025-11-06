local gpu_adapters = require('utils.gpu-adapter')

return {
    max_fps = 120,
    front_end = 'WebGpu',
    automatically_reload_config = true,
    webgpu_power_preference = 'HighPerformance',
    webgpu_preferred_adapter = gpu_adapters:pick_best(),
    native_macos_fullscreen_mode = true,
    -- webgpu_preferred_adapter = gpu_adapters:pick_manual('Dx12', 'IntegratedGpu'),
    -- webgpu_preferred_adapter = gpu_adapters:pick_manual('Gl', 'Other'),
    underline_thickness = '1.5pt',

    -- cursor
    animation_fps = 120,
    cursor_blink_ease_in = 'EaseOut',
    cursor_blink_ease_out = 'EaseOut',
    default_cursor_style = 'BlinkingBlock',
    cursor_blink_rate = 650,

    -- color scheme
    color_scheme = "Catppuccin Mocha",

    -- background
    macos_window_background_blur = 50,
    background = {
        {
            source = {
                Color = "#171B22",
            },
            width = "100%",
            height = "100%",
            opacity = 0.8,
        },
    },

    -- scrollbar
    enable_scroll_bar = true,

    -- tab bar
    enable_tab_bar = true,
    hide_tab_bar_if_only_one_tab = false,
    use_fancy_tab_bar = false,
    tab_max_width = 20,
    show_tab_index_in_tab_bar = false,
    switch_to_last_active_tab_when_closing_tab = true,

    -- window
    initial_rows = 40,
    initial_cols = 100,
    window_padding = {
        left = 2.5,
        right = 2.5,
        top = 10,
        bottom = 7.5,
    },
    adjust_window_size_when_changing_font_size = false,
    window_close_confirmation = 'NeverPrompt',
    window_frame = {
        active_titlebar_bg = '#090909',
        border_bottom_height = "0.2cell",
        -- font = fonts.font,
        -- font_size = fonts.font_size,
    },
    -- inactive_pane_hsb = {
    --    saturation = 0.9,
    --    brightness = 0.65,
    -- },
    inactive_pane_hsb = {
        saturation = 1,
        brightness = 1,
    },

    visual_bell = {
        fade_in_function = 'EaseIn',
        fade_in_duration_ms = 250,
        fade_out_function = 'EaseOut',
        fade_out_duration_ms = 250,
        target = 'CursorColor',
    },
}
