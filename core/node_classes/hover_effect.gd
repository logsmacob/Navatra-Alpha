extends Node
class_name HoverEffect

@export var hover_amount: float = -0.25
@export var selected_hover_amount: float = -0.85
@export var normal_y: float = 0.0
@export var selected_y: float = -1.1

@export var tween_duration: float = 0.1
@export var selected_tween_duration: float = 0.2

@export var is_selected: bool = false
@export var interaction_enabled: bool = true

var _y_tween: Tween

@onready var parent_node: Control = get_parent()

func _ready() -> void:
	parent_node.mouse_entered.connect(_on_mouse_entered)
	parent_node.mouse_exited.connect(_on_mouse_exited)

func _on_mouse_entered() -> void:
	if not interaction_enabled:
		return

	
	if parent_node == null:
		return

	if not is_selected:
		_hover(parent_node, hover_amount)
	else:
		_hover(parent_node, selected_hover_amount)


func _on_mouse_exited() -> void:
	if not interaction_enabled:
		return

	if parent_node == null:
		return

	if not is_selected:
		_hover(parent_node, normal_y)
	else:
		_hover(parent_node, selected_y)


func animate_selection() -> void:
	if parent_node == null:
		return

	var target_y: float = (selected_y * parent_node.size.y) if is_selected else 0.0
	_tween_position_y(parent_node, target_y, selected_tween_duration)


func _hover(target: Node, amount: float) -> void:
	if not target.has_method("get"):
		return

	var size = target.get("size") if target.has_method("get") else Vector2.ONE
	var target_y: float = amount * size.y
	_tween_position_y(target, target_y, tween_duration)


func _tween_position_y(target: Node, target_y: float, duration: float) -> void:
	if _y_tween != null and _y_tween.is_valid():
		_y_tween.kill()

	_y_tween = create_tween()
	_y_tween.tween_property(target, "position:y", target_y, duration)
