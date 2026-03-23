extends RichTextEffect
class_name WaveEffect

var bbcode := "wave"

@export var amplitude: float = 10.0
@export var frequency: float = 6.0
@export var speed: float = 6.0

func _process_custom_fx(char_fx: CharFXTransform) -> bool:
	var t: float = Time.get_ticks_msec() / 1000.0

	char_fx.offset.y = sin(
		t * speed + float(char_fx.absolute_index) * frequency * 0.1
	) * amplitude

	return true
