extends Node2D

func _ready():
	var data = DatabaseManager.get_data()
	for row in data:
		print("Data:", row["status"])

@warning_ignore("unused_parameter")
func _process(delta):
	pass

func _input(event):
	if event.is_action_pressed("toggle_boat_scene"):
		get_tree().change_scene_to_file("res://Scenes/OnBoat.tscn")
