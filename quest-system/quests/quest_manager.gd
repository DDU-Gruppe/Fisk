extends Node

class_name QuestManager

var quests = []

func add_quest(quest: Quest) -> void:
    quests.append(quest)

func get_quest(index: int) -> Quest:
    return quests[index] if index >= 0 and index < quests.size() else null

func all_quests_completed() -> bool:
    for quest in quests:
        if not quest.is_completed:
            return false
    return true

func get_completed_quests() -> Array:
    return quests.filter((quest) -> quest.is_completed)