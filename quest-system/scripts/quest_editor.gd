extends Node

# QuestEditor class for managing the quest editing interface
class_name QuestEditor

var quest_manager: QuestManager
var current_quest: Quest

# Called when the node enters the scene tree for the first time.
func _ready():
    quest_manager = preload("res://quests/quest_manager.gd").new()
    load_quests()

# Load quests from the QuestManager
func load_quests():
    # Logic to load quests and update the UI
    pass

# Save the current quest
func save_quest():
    if current_quest:
        # Logic to save the current quest
        pass

# Update the UI based on the selected quest
func update_ui():
    if current_quest:
        # Logic to update UI elements with current quest data
        pass

# Create a new quest
func create_quest(name: String, description: String, objectives: Array, reward: int):
    var new_quest = Quest.new()
    new_quest.name = name
    new_quest.description = description
    new_quest.objectives = objectives
    new_quest.reward = reward
    quest_manager.add_quest(new_quest)
    update_ui()