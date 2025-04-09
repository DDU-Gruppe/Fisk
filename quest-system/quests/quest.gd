extends Resource

class_name Quest

export(String) var name
export(String) var description
export(Array, String) var objectives
export(int) var reward
export(bool) var is_completed = false

func is_quest_completed() -> bool:
    return is_completed

func update_quest_status(completed: bool) -> void:
    is_completed = completed