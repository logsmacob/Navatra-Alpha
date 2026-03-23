extends RichTextLabel

@export var reveal_speed: float = 30.0

var _visible_chars: float = 0.0

func _ready() -> void:
	visible_characters = 0
	


func _process(delta: float) -> void:
	_visible_chars += reveal_speed * delta
	visible_characters = int(_visible_chars)

func _show() -> void:
	super.show()
	_visible_chars = 0.0
	visible_characters = 0
