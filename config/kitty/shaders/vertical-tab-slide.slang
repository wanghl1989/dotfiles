#language slang 2026

import kitty_custom_shader_types;

static const float CORNER_RADIUS = 0.28;
static const float LEFT_PADDING = 0.25;

float3 linear_to_srgb(float3 value) {
    return select(value <= 0.0031308, value * 12.92, 1.055 * pow(max(value, float3(0.0)), float3(1.0 / 2.4)) - 0.055);
}

float4 sample_at(KittyTexture texture, float2 size, float x, float y) {
    // Python coordinates start upper-left; shader UV starts lower-left.
    return texture.Sample(float2(x / size.x, 1.0 - y / size.y));
}

int read_marker(float4 color, int signature) {
    float3 srgb = linear_to_srgb(color.rgb / max(color.a, 0.00001)) * 255.0;
    int3 levels = int3(round((srgb - 96.0) / 5.0));
    if (any(levels < 0) || any(levels > 31)
            || any(abs(srgb - (96.0 + 5.0 * float3(levels))) > 1.25)) return -1;
    int value = (levels.x << 10) | (levels.y << 5) | levels.z;
    return (value >> 13) == signature ? value & 8191 : -1;
}

struct Record {
    float top;
    float cell_height;
    float cell_width;
    float right;
    float2 bounds;
    float3 highlight;
    float3 inactive_ink;
    float3 active_ink;
};

bool read_record(KittyTexture texture, float2 size, out Record record) {
    record = {};
    // Eight-pixel probes cannot skip a supported header cell. Coordinate
    // signatures distinguish the record from ordinary theme backgrounds.
    for (int probe = 0; probe < 768; probe += 8) {
        float y = float(probe) + 0.5;
        if (y >= size.y) break;
        int height = read_marker(sample_at(texture, size, 0.5, y), 3);
        if (height < 8 || height > 256) continue;
        int width = read_marker(sample_at(texture, size, 0.5, y + float(height)), 1);
        if (width < 2 || width > 256) continue;
        float x = float(width) * 1.5;
        int top = read_marker(sample_at(texture, size, x, y), 2);
        if (top < 0 || top >= 512 || y < float(top) || y >= float(top + height)) continue;
        float middle = float(top) + float(height) * 0.5;
        int right = read_marker(sample_at(texture, size, x, middle + float(height)), 2);
        int start = read_marker(sample_at(texture, size, 0.5, middle + 2.0 * float(height)), 1);
        int end = read_marker(sample_at(texture, size, x, middle + 2.0 * float(height)), 2);
        if (right < width * 5 || float(right) > size.x || start < top || end <= start || float(end) > size.y) continue;
        record.top = float(top);
        record.cell_height = float(height);
        record.cell_width = float(width);
        record.right = float(right);
        record.bounds = float2(float(start), float(end));
        float4 hi = sample_at(texture, size, x, middle + 3.0 * float(height));
        float4 fg = sample_at(texture, size, 0.5, middle + 4.0 * float(height));
        float4 af = sample_at(texture, size, x, middle + 4.0 * float(height));
        record.highlight = hi.rgb / max(hi.a, 0.00001);
        record.inactive_ink = fg.rgb / max(fg.a, 0.00001);
        record.active_ink = af.rgb / max(af.a, 0.00001);
        return true;
    }
    return false;
}

float rounded_rect(float2 position, float4 rect, float radius) {
    float2 half_size = (rect.zw - rect.xy) * 0.5;
    float2 center = (rect.xy + rect.zw) * 0.5;
    float2 delta = abs(position - center) - half_size + radius;
    float distance = length(max(delta, float2(0.0))) + min(max(delta.x, delta.y), 0.0) - radius;
    return saturate(0.5 - distance);
}

public float4 fragment_main(float4 color, KittyTextures t, uniform KittyCustomShaderData d) {
    if (d.central_area.x <= 0.0 || t.pos.x >= d.central_area.x) return color;
    float2 size = float2(d.viewport_size_pixels);
    Record record;
    if (!read_record(t.backbuffer, size, record)) return color;
    float2 position = float2(t.pos.x * size.x, (1.0 - t.pos.y) * size.y);
    if (position.x >= record.right) return color;

    bool metadata = position.x < 2.0 * record.cell_width
        && position.y >= record.top && position.y < record.top + 5.0 * record.cell_height;
    // Texture samples are premultiplied, but kitty passes fragment_main's
    // color in straight alpha and premultiplies our return value itself.
    float4 base = sample_at(t.backbuffer, size, record.right - 0.5, position.y);
    base.rgb /= max(base.a, 0.00001);
    if (metadata) color = base;
    float inset = max(1.0, record.cell_height * 0.08);
    // Keep the fill inside the sidebar, with space before the title's two
    // padding columns. The existing right inset stays independent.
    float left_inset = min(max(0.0, LEFT_PADDING) * record.cell_height, record.cell_width * 1.5);
    float4 rect = float4(left_inset, record.bounds.x + 0.5,
                        record.right - inset, record.bounds.y - 0.5);
    float radius = min(max(0.0, CORNER_RADIUS) * record.cell_height,
                       min(rect.z - rect.x, rect.w - rect.y) * 0.5);
    float fill = rounded_rect(position, rect, radius);
    if (fill <= 0.0) return color;

    float3 delta = record.inactive_ink - base.rgb;
    float effective_coverage = metadata ? 0.0 : saturate(dot(color.rgb - base.rgb, delta) / max(dot(delta, delta), 0.00001));
    // Bell symbols and emoji may have their own colors. Keep those glyph
    // pixels instead of forcing them into the monochrome title palette.
    if (any(abs(color.rgb - lerp(base.rgb, record.inactive_ink, effective_coverage)) > 0.03)) return color;
    // Undo the straight-alpha normalization to recover the actual glyph
    // coverage before changing the background's opacity.
    float coverage = effective_coverage * base.a / max(1.0 - effective_coverage * (1.0 - base.a), 0.00001);
    float background_alpha = lerp(base.a, 1.0, fill);
    float3 background = lerp(base.rgb, record.highlight, fill) * background_alpha;
    float3 ink = lerp(record.inactive_ink, record.active_ink, fill);
    float alpha = lerp(background_alpha, 1.0, coverage);
    return float4(lerp(background, ink, coverage) / max(alpha, 0.00001), alpha);
}
