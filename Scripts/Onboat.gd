extends Node2D

var is_fishing: bool = false
@onready var Lilbuddyman: CharacterBody2D = get_node("Lilbuddyman")

func _ready():
	if not Lilbuddyman:
		printerr("Error: 'Lilbuddyman' node not found!")
	else:
		print("onboat: Lilbuddyman found.")
		original_position = boat_character.position
		print("Original position of lilbuddyman:", original_position)
		
	var quest = preload("res://Quest System/20_fish.tres")
	$UI/QuestDisplay.set_quest(quest)
	$UI/QuestDisplay.update_from_db(quest.fish_column)

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
