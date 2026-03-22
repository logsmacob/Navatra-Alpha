extends Node

class_name HandButtonManager

const DEFAULT_SCALE := Vector2.ONE
const HOVER_SCALE := Vector2(1.05, 1.05)
const HOVER_DURATION := 0.1
const PRESS_DURATION := 0.05
const PLAY_HOLD_DELAY_SECONDS := 0.5

@export var play_hand: TextureButton
@export var re_roll: TextureButton

var _button_tweens: Dictionary = {}
var _play_hold_timer: SceneTreeTimer
var _play_hold_active: bool = false

signal play_hold_started
signal play_hold_ended

func _ready() -> void:
	_setup_button(play_hand)
	_setup_button(re_roll)

func _setup_button(button: TextureButton) -> void:
	if button == null:
		return

	button.pivot_offset = button.size * 0.5
	button.resized.connect(_on_button_resized.bind(button))
	button.mouse_entered.connect(_on_button_hovered.bind(button))
	button.mouse_exited.connect(_on_button_unhovered.bind(button))
	button.button_down.connect(_on_button_pressed.bind(button))
	button.button_up.connect(_on_button_released.bind(button))

func _on_button_resized(button: TextureButton) -> void:
	button.pivot_offset = button.size * 0.5

func _on_button_hovered(button: TextureButton) -> void:
	if button.disabled:
		return
	_animate_button_scale(button, HOVER_SCALE, HOVER_DURATION)

func _on_button_unhovered(button: TextureButton) -> void:
	_animate_button_scale(button, DEFAULT_SCALE, HOVER_DURATION)

func _on_button_pressed(button: TextureButton) -> void:
	_animate_button_scale(button, DEFAULT_SCALE, PRESS_DURATION)
	if button == play_hand:
		_start_play_hold_tracking()

func _on_button_released(button: TextureButton) -> void:
	if button == play_hand:
		_stop_play_hold_tracking()

func _start_play_hold_tracking() -> void:
	_play_hold_active = false
	_play_hold_timer = get_tree().create_timer(PLAY_HOLD_DELAY_SECONDS)
	await _play_hold_timer.timeout
	if play_hand != null and play_hand.button_pressed and not play_hand.disabled:
		_play_hold_active = true
		play_hold_started.emit()

func _stop_play_hold_tracking() -> void:
	if _play_hold_active:
		play_hold_ended.emit()
	_play_hold_active = false
	_play_hold_timer = null

func _animate_button_scale(button: TextureButton, target_scale: Vector2, duration: float) -> void:
	var existing_tween: Tween = _button_tweens.get(button)
	if existing_tween != null:
		existing_tween.kill()

	var tween := create_tween()
	_button_tweens[button] = tween
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(button, "scale", target_scale, duration)

func disable_buttons():
	play_hand.disabled = true
	re_roll.disabled = true
	_stop_play_hold_tracking()
	_animate_button_scale(play_hand, DEFAULT_SCALE, PRESS_DURATION)
	_animate_button_scale(re_roll, DEFAULT_SCALE, PRESS_DURATION)
	play_hand.modulate = Color(1, 1, 1, 0.5)
	re_roll.modulate = Color(1, 1, 1, 0.5)

func enable_buttons():
	play_hand.disabled = false
	re_roll.disabled = false
	play_hand.modulate = Color.WHITE
	re_roll.modulate = Color.WHITE

func update_button_labels():
	play_hand.get_child(0).text = "Play Hand\nx%d" % int(GameState.get_round_state().get("hands_remaining", 0))
	re_roll.get_child(0).text = "Re-Roll\nx%d" % int(GameState.get_round_state().get("rerolls_remaining", 0))
