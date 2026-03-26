extends Button

@export var title_label: Label
@export var discription_label: Label
@export var price_label: Label
@export var rarity_label: Label
@export var texture_rect: TextureRect

func set_title(title: String):
	title_label.text = title

func set_discription(discription: String):
	discription_label.text = discription

func set_price(price: int):
	price_label.text = "%d" % price

func set_rarity(rarity: String):
	rarity_label.text = rarity

func set_texture(texture: AtlasTexture):
	texture_rect.texture = texture

func set_border_color(new_color: Color):
	self_modulate = new_color
	rarity_label.modulate = new_color

func _on_mouse_entered() -> void:
	z_index = 1

func _on_mouse_exited() -> void:
	z_index = 0
