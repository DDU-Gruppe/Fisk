extends Node2D
@export var fishing_game_scene: PackedScene  # Set in Inspector

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
	
func _input(event):
	if event.is_action_pressed("toggle_boat_scene"):
		get_tree().change_scene_to_file("res://Scenes/main game.tscn")
	
	if event.is_action_pressed("start_fishing"):
		if fishing_game_scene:
			get_tree().paused=true
			PhysicsServer2D.set_active(true)
			
			var fishingGame = preload("res://Scenes/fishing_minigame.tscn").instantiate()
			get_tree().current_scene.add_child(fishingGame)
