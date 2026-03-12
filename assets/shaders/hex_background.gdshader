shader_type canvas_item;

uniform vec4 color_a : source_color = vec4(0.1, 0.3, 0.8, 1.0);
uniform vec4 color_b : source_color = vec4(0.9, 0.2, 0.5, 1.0);
uniform vec4 edge_color : source_color = vec4(0.5, 0.3, 0.9, 1.0);

uniform float hexes_across : hint_range(5.0, 80.0) = 50.0;
uniform float speed : hint_range(0.1, 5.0) = 2.5;

uniform float ripple_frequency : hint_range(0.5, 5.0) = 1.8;
uniform float randomness : hint_range(0.0, 1.0) = 0.35;

uniform float edge_thickness : hint_range(0.0, 0.2) = 0.05;
uniform float edge_softness : hint_range(0.0, 0.1) = 0.01;


// -------- Hex Math --------

vec3 cube_round(vec3 cube) {
    vec3 r = round(cube);
    vec3 diff = abs(r - cube);

    if (diff.x > diff.y && diff.x > diff.z)
        r.x = -r.y - r.z;
    else if (diff.y > diff.z)
        r.y = -r.x - r.z;
    else
        r.z = -r.x - r.y;

    return r;
}

vec3 pixel_to_hex(vec2 p, float hex_size) {
    float q = (sqrt(3.0)/3.0 * p.x - 1.0/3.0 * p.y) / hex_size;
    float r = (2.0/3.0 * p.y) / hex_size;
    return vec3(q, r, -q - r);
}

vec2 hex_to_pixel(vec3 h, float hex_size) {
    float x = hex_size * (sqrt(3.0) * h.x + sqrt(3.0)/2.0 * h.y);
    float y = hex_size * (3.0/2.0 * h.y);
    return vec2(x, y);
}

float hex_distance(vec2 p) {
    p = abs(p);
    return max(dot(p, normalize(vec2(1.0, 1.7320508))), p.x);
}


// -------- Fragment --------

void fragment() {

    vec2 viewport_size = 1.0 / SCREEN_PIXEL_SIZE;
    float hex_size = viewport_size.x / hexes_across;

    vec2 pos = FRAGCOORD.xy;

    vec3 hex = pixel_to_hex(pos, hex_size);
    vec3 rounded = cube_round(hex);

    vec2 center = hex_to_pixel(rounded, hex_size);
    vec2 local = pos - center;

    float dist = hex_distance(local / hex_size);

    vec2 screen_center = viewport_size * 0.5;

    float radial = length(center - screen_center) / hex_size;

    float random_offset = fract(
        sin(dot(rounded.xy, vec2(12.9898, 78.233))) * 43758.5453
    );

    float wave = sin(
        TIME * speed
        - radial * ripple_frequency
        + random_offset * 6.28318 * randomness
    );

    float t = (wave + 1.0) * 0.5;

    vec4 col = mix(color_a, color_b, t);

    // -------- Edge Band --------
    float outer = smoothstep(1.0, 1.0 - edge_softness, dist);
    float inner = smoothstep(1.0 - edge_thickness, 1.0 - edge_thickness - edge_softness, dist);

    float edge = outer - inner;

    col = mix(col, edge_color, edge);

    // Subtle vignette
    float vignette = smoothstep(
        1.3,
        0.2,
        length(pos - screen_center) / viewport_size.x
    );

    col *= vignette * 0.25 + 0.75;

    COLOR = col;
}
