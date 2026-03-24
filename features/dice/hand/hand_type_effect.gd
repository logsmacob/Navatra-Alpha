extends RichTextLabel

@export var reveal_speed: float = 30.0

var _visible_chars: float = 0.0
var _is_hiding: bool = false

func _ready() -> void:
	visible_characters = 0

func _process(delta: float) -> void:
	if _is_hiding:
		_visible_chars -= reveal_speed * delta
	else:
		_visible_chars += reveal_speed * delta

	_visible_chars = clamp(_visible_chars, 0.0, float(text.length()))
	visible_characters = int(_visible_chars)

	# When fully hidden → actually hide node
	if _is_hiding and _visible_chars <= 0.0:
		super.hide()

func show_with_reveal() -> void:
	super.show()
	_is_hiding = false
	_visible_chars = 0.0
	visible_characters = 0

func hide_with_reveal() -> void:
	# Start reverse animation instead of instantly hiding
	_is_hiding = true
