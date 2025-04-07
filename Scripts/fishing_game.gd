extends Control

@onready var catch_bar: ProgressBar = %CatchBar

var onCatch: bool = false
var catchSpeed: float = 0.3
var catchingValue: float = 0.0
signal win

# Define an array with the available fish column names.
var fish_data = [
	{ "column": "laks" },
	{ "column": "torsk" },
	{ "column": "bluefish" },
	{ "column": "tun" }
]

var current_fish: Dictionary = {}

func _ready() -> void:
	randomize()  # Seed the random number generator.
	select_random_fish()
	# Connect the win signal to the DatabaseManager's _on_fishing_win() method.
	connect("win", Callable(DatabaseManager, "_on_fishing_win"))

func select_random_fish() -> void:
	var chosen_index = randi() % fish_data.size()
	current_fish = fish_data[chosen_index]
	print("Selected fish: ", current_fish.column)

func _physics_process(delta: float) -> void:
	if onCatch:
		catchingValue += catchSpeed
	else:
		catchingValue -= catchSpeed
	catchingValue = clamp(catchingValue, 0.0, 100.0)
	catch_bar.value = catchingValue
	if catchingValue >= 100.0:
		_game_end()
		get_tree().change_scene_to_file("res://Scenes/main game.tscn")

func _game_end() -> void:
	var tween = get_tree().create_tween()
	# Emit the win signal with the selected fish column name.
	emit_signal("win", current_fish.column)
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(self, "global_position", global_position + Vector2(0, 700), 0.5)
	await tween.finished
	get_tree().paused = false
	queue_free()

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		_game_end()
		get_tree().change_scene_to_file("res://Scenes/main game.tscn")

func _on_target_target_entered() -> void:
	onCatch = true

func _on_target_target_exited() -> void:
	onCatch = false
