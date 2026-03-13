shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform float radius = 100.0;

void fragment() {
    vec2 texel = 1.0 / vec2(textureSize(SCREEN_TEXTURE, 0));
    vec4 color = vec4(0.0);
    float total = 0.0;

    for (int x = -4; x <= 4; x++) {
        for (int y = -4; y <= 4; y++) {

            vec2 offset = vec2(float(x), float(y));

            float weight = 1.0 - length(offset) / radius;
            weight = max(weight, 0.0);

            color += texture(SCREEN_TEXTURE, SCREEN_UV + offset * texel) * weight;
            total += weight;
        }
    }

    COLOR = color / total;
}
