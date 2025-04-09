extends CharacterBody2D

@export var speed: float = 70.0
var can_move: bool = true

func _physics_process(delta: float) -> void:
	if can_move:
		var input_vector = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		if input_vector != Vector2.ZERO:
			input_vector = input_vector.normalized()
		velocity = input_vector * speed
		move_and_slide()
