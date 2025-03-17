extends Area2D
@export var aquaContainer: Control

signal target_entered()
signal target_exited()

const SPEED := 200

var on_fish := false

func _physics_process(delta: float) -> void:
	_check_on_fish()

	var direction := Vector2.ZERO
	direction.x = Input.get_axis("ui_left", "ui_right")
	direction.y = Input.get_axis("ui_up", "ui_down")
	
	global_position += direction * SPEED * delta

	# Begræns positionen inden for aquaContainer
	_clamp_to_aqua_container()

func _clamp_to_aqua_container() -> void:
	if aquaContainer:
		var min_x = aquaContainer.global_position.x
		var max_x = min_x + aquaContainer.size.x
		var min_y = aquaContainer.global_position.y
		var max_y = min_y + aquaContainer.size.y

		global_position.x = clamp(global_position.x, min_x, max_x)
		global_position.y = clamp(global_position.y, min_y, max_y)

func _check_on_fish() -> void:
	var bodies := get_overlapping_bodies()

	if bodies.is_empty() and on_fish: 
		on_fish = false
		target_exited.emit()
	elif not bodies.is_empty() and not on_fish: 
		on_fish = true
		target_entered.emit()
