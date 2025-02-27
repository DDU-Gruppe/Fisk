extends CharacterBody2D

# Tugboat properties
@export var max_speed: float = 200.0
@export var acceleration: float = 50.0
@export var turn_speed: float = 1.5      # Slower turning for realism
@export var water_resistance: float = 0.95  # Slows down over time
@export var glide_factor: float = 0.98      # Glide effect when not accelerating

# Cartoony effects
@export var bob_amplitude: float = 5.0     # How much the boat bobs up and down
@export var bob_speed: float = 2.0         # Speed of bobbing
@export var splash_effect: PackedScene    # Splash particle effect

# Internal variables
var current_bob: float = 0.0

func _ready():
	# Start bobbing animation
	current_bob = randf() * 2 * PI  # Randomize bobbing phase

func _physics_process(delta):
	handle_input(delta)
	apply_water_resistance()
	apply_glide()
	apply_bobbing(delta)
	move_and_slide()

	# Play splash effect if moving fast enough
	if velocity.length() > 50:
		spawn_splash()

func handle_input(delta):
	# Rotation (steering)
	if Input.is_action_pressed("ui_left"):
		rotation -= turn_speed * delta
	if Input.is_action_pressed("ui_right"):
		rotation += turn_speed * delta

	# Forward and backward movement
	var input_direction = 0.0
	if Input.is_action_pressed("ui_up"):
		input_direction = 1.0
	if Input.is_action_pressed("ui_down"):
		input_direction = -0.5  # Reverse should be slower

	# Apply acceleration in the direction the boat is facing
	if input_direction != 0:
		velocity += Vector2.RIGHT.rotated(rotation) * acceleration * input_direction * delta
		velocity = velocity.limit_length(max_speed)

func apply_water_resistance():
	# Gradually slow down the boat due to water resistance
	velocity *= water_resistance

func apply_glide():
	# Glide effect when not accelerating
	if Input.is_action_just_released("ui_up") or Input.is_action_just_released("ui_down"):
		velocity *= glide_factor

func apply_bobbing(delta):
	# Cartoony bobbing effect
	current_bob += bob_speed * delta
	var bob_offset = sin(current_bob) * bob_amplitude
	position.y += bob_offset * delta

func spawn_splash():
	# Spawn a splash effect at the sides of the boat
	if splash_effect:
		var left_splash = splash_effect.instantiate()
		var right_splash = splash_effect.instantiate()

		# Position splashes at the sides of the boat (adjusted for isometric view)
		left_splash.position = position + Vector2(-20, 10).rotated(rotation)
		right_splash.position = position + Vector2(20, 10).rotated(rotation)

		# Add splashes to the scene
		get_parent().add_child(left_splash)
		get_parent().add_child(right_splash)
