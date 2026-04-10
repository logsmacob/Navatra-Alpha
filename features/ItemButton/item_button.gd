extends Button

signal lock_toggled(is_locked: bool)

@export var title_label: Label
@export var discription_label: Label
@export var price_label: Label
@export var rarity_label: Label
@export var texture_rect: TextureRect
@export var lock_button: CheckButton

func _ready() -> void:
	if lock_button != null:
		lock_button.toggled.connect(_on_lock_toggled)

func set_title(title: String):
	title_label.text = title

func set_description(description: String):
	discription_label.text = description

# Backward-compatible alias for old call sites.
func set_discription(discription: String):
	set_description(discription)

func set_price(price: int):
	price_label.text = "%d" % price

func set_rarity(rarity: String):
	rarity_label.text = rarity

func set_texture(texture: AtlasTexture):
	texture_rect.texture = texture

func set_border_color(new_color: Color):
	self_modulate = new_color
	rarity_label.modulate = new_color

func set_locked(is_locked: bool) -> void:
	if lock_button == null:
		return
	lock_button.set_pressed_no_signal(is_locked)

func is_locked() -> bool:
	if lock_button == null:
		return false
	return lock_button.button_pressed

func _on_mouse_entered() -> void:
	z_index = 1

func _on_mouse_exited() -> void:
	z_index = 0

func _on_lock_toggled(is_locked: bool) -> void:
	lock_toggled.emit(is_locked)
