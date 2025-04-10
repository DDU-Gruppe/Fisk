extends Node

# Static flags to persist state even if the script is reloaded.
static var instance_initialized: bool = false
static var number_incremented: bool = false

func _ready():
	# Load the quest resource
	var quest = preload("res://Quest System/20_fish.tres")
	$QuestDisplay.set_quest(quest)
	#$QuestDisplay.update_from_db(quest.fish_column)


	# Instantiate the SQLite object (assuming the plugin registers a global class named "SQLite").
func _input(event):
	if event.is_action_pressed("toggle_boat_scene"):
		get_tree().change_scene_to_file("res://Scenes/OnBoat.tscn")
