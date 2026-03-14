extends Control

@export var play: Button
@export var discord: Button
@export var quit: Button

func _ready() -> void:
	play.pressed.connect(play_pressed)
	discord.pressed.connect(discord_pressed)
	quit.pressed.connect(quit_pressed)

func play_pressed():
	# change to your game scene
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func discord_pressed():
	# open discord invite in browser
	OS.shell_open("https://discord.gg/8aeDzcgH")

func quit_pressed():
	get_tree().quit()
