extends Control
## Title screen script: coordinates this part of the game's behavior.

const DEFAULT_MAIN_SCENE := preload("res://scenes/main/main.tscn")

@export var play: TextureButton
@export var discord: TextureButton
@export var quit: TextureButton
@export var main_scene: PackedScene = DEFAULT_MAIN_SCENE

func _ready() -> void:
	play.pressed.connect(play_pressed)
	discord.pressed.connect(discord_pressed)
	quit.pressed.connect(quit_pressed)

func play_pressed():
	if main_scene == null:
		push_warning("TitleScreen: main_scene is not assigned.")
		return
	var scene_tree := get_tree()
	if scene_tree == null:
		return
	scene_tree.change_scene_to_packed(main_scene)

func discord_pressed():
	# open discord invite in browser
	OS.shell_open("https://discord.gg/azzAAPUrRB")

func quit_pressed():
	get_tree().quit()
