extends CharacterBody2D

@export var speed: float = 70.0
@export var fishing_game_scene: PackedScene  # Assign your fishing minigame scene here.
var can_move: bool = true
var is_fishing: bool = false
var original_position: Vector2

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

signal fishing_minigame_started

func _ready() -> void:
	original_position = position
	print("Lilbuddyman ready. Original position:", original_position)

func _physics_process(delta: float) -> void:
	if can_move and not is_fishing:
		var input_vector = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		if input_vector != Vector2.ZERO:
			input_vector = input_vector.normalized()
			velocity = input_vector * speed
			if not animated_sprite.is_playing() or animated_sprite.animation != "Walk":
				animated_sprite.play("Walk")
			animated_sprite.flip_h = input_vector.x > 0
		else:
			velocity = Vector2.ZERO
			animated_sprite.stop()
			animated_sprite.frame = 0
	move_and_slide()

func _input(event):
	if event.is_action_pressed("start_fishing") and not is_fishing:
		startFishingMode()

func startFishingMode() -> void:
	is_fishing = true
	can_move = false
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position:x", 0.0, 0.5)
	await tween.finished
	print("Reached left side. Playing 'Fishing' animation.")
	animated_sprite.play("Fishing")
	var anim_length = get_animation_length(animated_sprite.sprite_frames, "Fishing")
	print("Computed Fishing animation length:", anim_length)
	if anim_length <= 0:
		print("Fishing animation length is zero; starting minigame immediately.")
		startFishingGame()
	else:
		# Create a timer that runs even if the scene is paused by passing false
		await get_tree().create_timer(anim_length, false).timeout
		print("Timer timeout reached. Starting fishing minigame.")
		startFishingGame()
	is_fishing = false

func get_animation_length(frames: SpriteFrames, anim_name: String) -> float:
	var total: float = 0.0
	var count: int = frames.get_frame_count(anim_name)
	for i in range(count):
		total += frames.get_frame_duration(anim_name, i)
	return total

func startFishingGame() -> void:
	if fishing_game_scene:
		var fishingGame = fishing_game_scene.instantiate()
		get_tree().current_scene.add_child(fishingGame)
		print("Fishing minigame instantiated.")
	emit_signal("fishing_minigame_started")
