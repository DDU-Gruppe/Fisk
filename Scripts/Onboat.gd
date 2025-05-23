extends Node2D

var is_fishing: bool = false
@onready var Lilbuddyman: CharacterBody2D = get_node("Lilbuddyman")

func _ready():
	if not Lilbuddyman:
		printerr("Error: 'Lilbuddyman' node not found!")
	else:
		print("onboat: Lilbuddyman found.")

func _process(_delta):
	pass

func _input(event):
	if event.is_action_pressed("toggle_boat_scene"):
		get_tree().change_scene_to_file("res://Scenes/main game.tscn")

	if event.is_action_pressed("start_fishing") and not is_fishing:
		if Lilbuddyman:
			is_fishing = true
			print("Starting fishing mode for Lilbuddyman.")
			Lilbuddyman.startFishingMode()
