extends CharacterBody2D

@export var speed := 200

func _physics_process(delta: float) -> void:
	# Get input from arrow keys (or WASD) mapped to ui_up, ui_down, ui_left, ui_right
	var input_vector = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	# Normalize to avoid faster diagonal movement
	if input_vector != Vector2.ZERO:
		input_vector = input_vector.normalized()
	
	velocity = input_vector * speed
	move_and_slide()
