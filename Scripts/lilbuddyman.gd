extends CharacterBody2D

@export var speed: float = 70.0
var can_move: bool = true

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	if can_move:
		var input_vector = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		
		if input_vector != Vector2.ZERO:
			input_vector = input_vector.normalized()
			velocity = input_vector * speed

			# Play walking animation
			if not animated_sprite.is_playing():
				animated_sprite.play("Walk")

			# Optional: Flip sprite depending on direction
			animated_sprite.flip_h = input_vector.x > 0
		else:
			velocity = Vector2.ZERO
			animated_sprite.stop()
			animated_sprite.frame = 0  # Reset to first frame or play "idle"

		move_and_slide()
