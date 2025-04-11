extends Resource
class_name Quest

@export var id : int
@export var name: String
@export var reward: int
@export var objective: String
@export var fish_column: String = ""
@export var use_total_fish: bool = false
@export var goal: int
@export var progress: int = 0
var start_value: int = 0  # new!

func is_complete() -> bool:
	return progress >= goal
