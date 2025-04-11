extends Node

var quest_active: bool = false

func activateQuest() -> void:
	quest_active = true
	DatabaseManager.set_quest_active(true)
	print("Quest activated.")

func deactivateQuest() -> void:
	quest_active = false
	DatabaseManager.set_quest_active(false)
	print("Quest deactivated.")
