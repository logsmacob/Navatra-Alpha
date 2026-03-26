shader_type canvas_item;

uniform float fov : hint_range(1.0, 179.0) = 90.0;
uniform bool cull_back = true;
uniform float y_rot : hint_range(-40.0, 40.0) = 0.0;
uniform float x_rot : hint_range(-40.0, 40.0) = 0.0;
uniform float inset : hint_range(0.0, 1.0) = 0.0;

varying flat vec2 offset;
varying vec3 perspective_position;

void vertex() {
	float sin_y = sin(y_rot / 180.0 * PI);
	float cos_y = cos(y_rot / 180.0 * PI);
	float sin_x = sin(x_rot / 180.0 * PI);
	float cos_x = cos(x_rot / 180.0 * PI);

	mat3 inverse_rotation;
	inverse_rotation[0][0] = cos_y;
	inverse_rotation[0][1] = 0.0;
	inverse_rotation[0][2] = -sin_y;
	inverse_rotation[1][0] = sin_y * sin_x;
	inverse_rotation[1][1] = cos_x;
	inverse_rotation[1][2] = cos_y * sin_x;
	inverse_rotation[2][0] = sin_y * cos_x;
	inverse_rotation[2][1] = -sin_x;
	inverse_rotation[2][2] = cos_y * cos_x;

	float tangent = tan(fov / 360.0 * PI);
	perspective_position = inverse_rotation * vec3(UV - 0.5, 0.5 / tangent);
	float projection = (0.5 / tangent) + 0.5;
	perspective_position.xy *= projection * inverse_rotation[2].z;
	offset = projection * inverse_rotation[2].xy;

	VERTEX += (UV - 0.5) / TEXTURE_PIXEL_SIZE * tangent * (1.0 - inset);
}

void fragment() {
	if (cull_back && perspective_position.z <= 0.0) {
		discard;
	}

	vec2 uv = (perspective_position.xy / perspective_position.z) - offset;
	COLOR = texture(TEXTURE, uv + 0.5);
	COLOR.a *= step(max(abs(uv.x), abs(uv.y)), 0.5);
}
