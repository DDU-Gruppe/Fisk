extends Resource

class_name Quest

@export var name: String
@export var reward: int
@export var objective: String
@export var progress: int = 0
@export var goal: int = 1

func is_complete() -> bool:
	return progress >= goal
