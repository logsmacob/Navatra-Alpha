extends Node
class_name ButtonScaleAnimator

@export var hover_scale: Vector2 = Vector2(1.05, 1.05)
@export var press_scale: Vector2 = Vector2(0.95, 0.95)
@export var duration: float = 0.1

var _button: BaseButton
var _tween: Tween

func _ready():
	_button = get_parent() as BaseButton
	
	if _button == null:
		push_error("ButtonScaleAnimator must be a child of a Button!")
		return
	
	# Center scaling
	_button.pivot_offset = _button.size * 0.5
	_button.resized.connect(_on_resized)

	# Signals
	_button.mouse_entered.connect(_on_hover)
	_button.mouse_exited.connect(_on_unhover)
	_button.button_down.connect(_on_pressed)
	_button.button_up.connect(_on_released)


func _on_resized():
	_button.pivot_offset = _button.size * 0.5


func _animate(target: Vector2):
	if _tween:
		_tween.kill()
	
	_tween = create_tween()
	_tween.set_trans(Tween.TRANS_BACK)
	_tween.set_ease(Tween.EASE_OUT)
	_tween.tween_property(_button, "scale", target, duration)


func _on_hover():
	if _button.disabled:
		return
	_animate(hover_scale)


func _on_unhover():
	_animate(Vector2.ONE)


func _on_pressed():
	_animate(press_scale)


func _on_released():
	# Return to hover or default depending on mouse
	if _button.get_rect().has_point(_button.get_local_mouse_position()):
		_animate(hover_scale)
	else:
		_animate(Vector2.ONE)
