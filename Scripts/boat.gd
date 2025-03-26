extends CharacterBody2D

@export var max_speed: float = 150.0
@export var acceleration: float = 30.0
@export var deceleration: float = 10.0
@export var turn_speed: float = 3.0
@export var bobbing_amount: float = 0.0  
@export var bobbing_speed: float = 1.5  
@export var bobbing_randomness: float = 1.0  
@export var crate_scene: PackedScene  # Set in Inspector
@export var max_crates: int = 5  # Maximum number of crates to create

# Crate weight parameters
@export var crate_drag: float = 0.1  # Drag per crate
@export var crate_turn_resistance: float = 0.2  # Resistance to turning per crate

# Internal variables
var current_bobbing_time: float = 0.0
var crates: Array = []
var ropes: Array = []  # Array to hold all rope instances
var can_add_crate: bool = true  # Flag to control crate addition

@export var crate_distance: float = 40.0  # Fixed distance between crates

@onready var noise = FastNoiseLite.new()

func _ready():
	noise.seed = randi()
	noise.frequency = 0.3  

func _physics_process(delta: float) -> void:
	handle_input(delta)
	apply_movement(delta)
	move_and_slide()
	update_crates_position(delta)

func handle_input(delta: float) -> void:
	var input_direction: Vector2 = Vector2.ZERO

	if Input.is_action_pressed("ui_up"):
		input_direction.y -= 1
	if Input.is_action_pressed("ui_down"):
		input_direction.y += 1
	if Input.is_action_pressed("ui_left"):
		input_direction.x -= 1
	if Input.is_action_pressed("ui_right"):
		input_direction.x += 1
	if Input.is_action_just_pressed("ui_accept") and crates.size() < max_crates and can_add_crate:
		add_crate()
		can_add_crate = false  # Prevent adding another crate until the flag is reset

	if input_direction.length() > 0:
		input_direction = input_direction.normalized()
		# Apply drag based on the number of crates
		var effective_acceleration = acceleration / (1 + crates.size() * crate_drag)
		velocity = velocity.move_toward(input_direction * (max_speed - (crates.size() * 10)), effective_acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, deceleration * delta)

	if velocity.length() > 0:
		# Apply turn resistance based on the number of crates
		var effective_turn_speed = turn_speed / (1 + crates.size() * crate_turn_resistance)
		var target_angle = velocity.angle()
		rotation = lerp_angle(rotation, target_angle, effective_turn_speed * delta)
	else:
		apply_bobbing(delta)

func apply_movement(delta: float) -> void:
	position += velocity * delta

func apply_bobbing(delta: float) -> void:
	current_bobbing_time += bobbing_speed * delta
	var noise_x = noise.get_noise_1d(current_bobbing_time) * bobbing_randomness
	var noise_y = noise.get_noise_1d(current_bobbing_time + 1000) * bobbing_randomness
	position.x += noise_x * bobbing_amount * delta
	position.y += noise_y * bobbing_amount * delta

func update_crates_position(_delta: float) -> void:
	# Update crate positions
	for i in range(crates.size()):
		var crate = crates[i]
		if crate:
			# Determine the position of each crate relative to the boat or the previous crate
			var target_position: Vector2
			if i == 0:
				# First crate follows the boat
				target_position = global_position - Vector2(cos(rotation), sin(rotation)) * crate_distance
			else:
				# Subsequent crates follow the previous crate
				target_position = crates[i - 1].global_position - Vector2(cos(crates[i - 1].rotation), sin(crates[i - 1].rotation)) * crate_distance

			# Smoothly move the crate towards the target position
			crate.global_position = crate.global_position.lerp(target_position, 0.1)  # Increased lerp weight for smoother movement

			# Follow the rotation of the boat
			crate.rotation = rotation

	# Update ropes
	update_ropes()

func update_ropes():
	# Clear existing ropes
	for rope in ropes:
		rope.queue_free()
	ropes.clear()

	# Create a new rope for each connection
	var previous_point = global_position
	for i in range(crates.size()):
		var crate = crates[i]
		if crate:
			# Create a new rope
			var rope = Line2D.new()
			rope.width = 2
			rope.default_color = Color(0.6, 0.4, 0.2)  # Brownish color for rope
			rope.points = [previous_point, crate.global_position]

			# Add the rope to the scene **before** the boat and crates
			get_parent().add_child(rope)
			get_parent().move_child(rope, 0)  # Move rope to the bottom of the scene tree (rendered first)

			ropes.append(rope)

			# Update the previous point
			previous_point = crate.global_position

func add_crate():
	if crate_scene:
		var crate = crate_scene.instantiate()
		get_parent().add_child(crate)

		# Position crate behind the last one or at the boat if it's the first crate
		var attach_point: Vector2
		if crates.size() > 0:
			attach_point = crates[-1].global_position - Vector2(cos(crates[-1].rotation), sin(crates[-1].rotation)) * crate_distance  # Behind last crate
		else:
			attach_point = global_position - Vector2(cos(rotation), sin(rotation)) * crate_distance  # Behind the boat

		crate.global_position = attach_point
		crates.append(crate)

		# Update ropes when a new crate is added
		update_ropes()

		# Reset the flag after a short delay to allow adding another crate
		await get_tree().create_timer(0.5).timeout  # 0.5-second cooldown
		can_add_crate = true
