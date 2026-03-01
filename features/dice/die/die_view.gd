extends Sprite2D

const HOLD_LIFT_Y: float = -80.0
const HOLD_LERP_SPEED: float = 10.0

# NOTE: Pure visual binding for one die model.
var model: DieModel
var base_position: Vector2
var hold_target_position: Vector2

func _ready() -> void:
	base_position = position
	hold_target_position = base_position + Vector2(0.0, HOLD_LIFT_Y)

func _process(delta: float) -> void:
	if model == null:
		return
	var target: Vector2 = base_position
	if model.is_held():
		target = hold_target_position
	position = position.lerp(target, delta * HOLD_LERP_SPEED)

func bind(die_model: DieModel) -> void:
	model = die_model
	model.value_changed.connect(_on_value_changed)
	model.hold_changed.connect(_on_hold_changed)
	_on_hold_changed(model.is_held())

func _on_value_changed(value: int) -> void:
	# Convention: 0 means "unrolled" visual state.
	frame = value - 1

func _on_hold_changed(is_held: bool) -> void:
	if is_held:
		z_index = 1
	else:
		z_index = 0
