shader_type canvas_item;

uniform vec4 color_a : source_color = vec4(0.016, 0.031, 0.161, 1.0);
uniform vec4 color_b : source_color = vec4(0.102, 0.165, 0.353, 1.0);
uniform vec4 edge_color : source_color = vec4(0.5, 0.3, 0.9, 1.0);

uniform float hexes_across : hint_range(5.0, 80.0) = 60.0;

uniform float swirl_speed : hint_range(0.1, 5.0) = 1.0;
uniform float swirl_scale : hint_range(0.1, 5.0) = 0.1;

uniform float edge_thickness : hint_range(0.0, 0.2) = 0.1;
uniform float edge_softness : hint_range(0.0, 0.1) = 0.1;


// -------- HEX GRID MATH --------

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

vec3 pixel_to_hex(vec2 p, float size) {
    float q = (sqrt(3.0)/3.0 * p.x - 1.0/3.0 * p.y) / size;
    float r = (2.0/3.0 * p.y) / size;
    return vec3(q, r, -q - r);
}

vec2 hex_to_pixel(vec3 h, float size) {
    float x = size * (sqrt(3.0) * h.x + sqrt(3.0)/2.0 * h.y);
    float y = size * (3.0/2.0 * h.y);
    return vec2(x, y);
}

float hex_distance(vec2 p) {
    p = abs(p);
    return max(dot(p, normalize(vec2(1.0, 1.7320508))), p.x);
}


// -------- FRAGMENT --------

void fragment() {

    vec2 viewport = 1.0 / SCREEN_PIXEL_SIZE;
    vec2 center_screen = viewport * 0.5;

    float hex_size = viewport.x / hexes_across;

    vec2 pos = FRAGCOORD.xy;

    vec3 hex = pixel_to_hex(pos, hex_size);
    vec3 rounded = cube_round(hex);

    vec2 center = hex_to_pixel(rounded, hex_size);
    vec2 local = pos - center;

    float dist = hex_distance(local / hex_size);

    // distance from screen center
    float radial = length(center - center_screen);

    // -------- BALATRO STYLE COLOR FLOW --------

    vec2 flow_pos = center * 0.02;

    float flow =
        sin(flow_pos.x * swirl_scale + TIME * swirl_speed) +
        sin(flow_pos.y * swirl_scale * 1.3 - TIME * swirl_speed * 1.2) +
        cos(radial * 0.015 - TIME * swirl_speed * 1.4);

    float t = flow * 0.5 + 0.5;

    vec4 col = mix(color_a, color_b, t);


    // -------- HEX EDGE --------

    float outer = smoothstep(1.0, 1.0 - edge_softness, dist);
    float inner = smoothstep(1.0 - edge_thickness, 1.0 - edge_thickness - edge_softness, dist);

    float edge = outer - inner;

    col = mix(col, edge_color, edge);


    // -------- VIGNETTE --------

    float vignette = smoothstep(
        1.3,
        0.2,
        length(pos - center_screen) / viewport.x
    );

    col *= vignette * 0.25 + 0.75;

    COLOR = col;
}
