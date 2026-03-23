extends RichTextLabel

@export var wave_speed := 6.0
@export var wave_height := 10.0
@export var scale_amount := 0.3

var time := 0.0
var text_length := 0

func _ready():
	text = "Hello World!"
	visible_characters = 0
	text_length = text.length()

func _process(delta):
	time += delta
	
	# reveal characters over time
	if visible_characters < text_length:
		visible_characters += 1

	queue_redraw()

func _draw():
	var font = get_theme_font("normal_font")
	var font_size = get_theme_font_size("normal_font_size")

	var x := 0.0

	for i in range(visible_characters):
		var char = text[i]

		# Wave offset
		var y_offset = sin(time * wave_speed + i * 0.5) * wave_height
		
		# Scale effect
		var scale = 1.0 + sin(time * wave_speed + i) * scale_amount
		
		var char_size = font.get_string_size(char, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size)
		
		draw_set_transform(Vector2(x, y_offset), 0, Vector2(scale, scale))
		draw_string(font, Vector2.ZERO, char, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size)

		draw_set_transform(Vector2.ZERO, 0, Vector2.ONE)

		x += char_size.x
