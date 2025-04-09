extends Node2D
var is_fishing: bool = false
@export var fishing_game_scene: PackedScene  # Set this in the Inspector to your fishing minigame scene.
var original_position: Vector2

# Reference the little man node. Adjust the path if needed.
@onready var boat_character: CharacterBody2D = get_node("Lilbuddyman")

func _ready():
	if boat_character == null:
		printerr("Error: 'lilbuddyman' node not found! Check node path.")
	else:
		original_position = boat_character.position
		print("Original position of lilbuddyman:", original_position)

func _process(_delta):
	pass

func _input(event):
	if event.is_action_pressed("toggle_boat_scene"):
		get_tree().change_scene_to_file("res://Scenes/main game.tscn")

	if event.is_action_pressed("start_fishing") && is_fishing == false:
		if fishing_game_scene:
			# Disable movement if necessary.
			if boat_character:
				boat_character.can_move = false
				is_fishing = true
			start_shake_animation()

func start_shake_animation():
	var tween = get_tree().create_tween()
	# Instead of moving 100 pixels to the right, now move 50 pixels to the left.
	tween.tween_property(boat_character, "position", original_position + Vector2(-50, 0), 0.3)
	# Create a small shake effect by oscillating around that offset.
	tween.tween_property(boat_character, "position", original_position + Vector2(-60, 0), 0.1)
	tween.tween_property(boat_character, "position", original_position + Vector2(-40, 0), 0.1)
	tween.tween_property(boat_character, "position", original_position + Vector2(-55, 0), 0.1)
	tween.tween_property(boat_character, "position", original_position + Vector2(-45, 0), 0.1)
	# Settle back at the offset.
	tween.tween_property(boat_character, "position", original_position + Vector2(-50, 0), 0.1)
	tween.connect("finished", Callable(self, "start_fishing_game"))

func start_fishing_game():
	if fishing_game_scene:
		var fishingGame = fishing_game_scene.instantiate()
		get_tree().current_scene.add_child(fishingGame)
		print("Fishing minigame instantiated.")
