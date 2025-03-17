extends Line2D

@export var MAX_LENGTH: int = 10
@export var parent: Node2D

@export var distance_at_largest_width: float = 16 * 6
@export var smallest_tip_width: float
@export var largest_tip_width: float

var length: float = 0.0
var queue: Array = []
var offset: Vector2 = Vector2.ZERO

func _ready():
	pass

func _process(_delta):
	length = 0.0

	if parent:
		var pos = parent.position
		queue.append(pos)
		if queue.size() > MAX_LENGTH and queue.size() > 2:
			queue.pop_front()

		clear_points()

		for i in range(queue.size() - 1):
			length += queue[i].distance_to(queue[i + 1])
			add_point(parent.to_local(queue[i]))
		add_point(parent.to_local(queue[queue.size() - 1]))

		var width_value = lerp(smallest_tip_width, largest_tip_width, inverse_lerp(0, distance_at_largest_width, length))
		width_curve.set_point_value(0, width_value)
	else:
		print("parent is not assigned")

func reset_line():
	clear_points()
	queue.clear()
