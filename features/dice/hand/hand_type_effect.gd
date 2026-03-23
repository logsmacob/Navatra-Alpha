extends RichTextLabel

@export var wave_speed := 6.0
@export var wave_height := 10.0
@export var scale_amount := 0.3

var time := 0.0
var text_length := 0
var rendered_text := ""

func _ready():
	rendered_text = get_parsed_text()
	visible_characters = 0
	text_length = rendered_text.length()

func _process(delta):
	time += delta

	var latest_text := get_parsed_text()
	if latest_text != rendered_text:
		rendered_text = latest_text
		text_length = rendered_text.length()
		visible_characters = 0

	# reveal characters over time
	if visible_characters < text_length:
		visible_characters += 1

	queue_redraw()

func _draw():
	var font = get_theme_font("normal_font")
	var font_size = get_theme_font_size("normal_font_size")
	if font == null or rendered_text.is_empty():
		return

	var total_width: float = font.get_string_size(rendered_text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
	var x: float = (size.x - total_width) * 0.5
	var baseline_y: float = (size.y + float(font_size)) * 0.5

	for i in range(visible_characters):
		var glyph := rendered_text[i]

		# Wave offset
		var y_offset = sin(time * wave_speed + i * 0.5) * wave_height

		# Scale effect
		var glyph_scale := 1.0 + sin(time * wave_speed + i) * scale_amount

		var char_size: Vector2 = font.get_string_size(glyph, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size)

		draw_set_transform(Vector2(x, baseline_y + y_offset), 0, Vector2(glyph_scale, glyph_scale))
		draw_string(font, Vector2.ZERO, glyph, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size)

		draw_set_transform(Vector2.ZERO, 0, Vector2.ONE)

		x += char_size.x
