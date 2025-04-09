extends CanvasLayer

@onready var name_label = $VBoxContainer/NameLabel
@onready var objective_label = $VBoxContainer/ObjectiveLabel
@onready var reward_label = $VBoxContainer/RewardLabel
@onready var progress_bar = $VBoxContainer/ProgressBar

var quest: Quest

func set_quest(new_quest: Quest):
	quest = new_quest
	update_display()

func update_display():
	name_label.text = "Quest: " + quest.name
	objective_label.text = "Objective: " + quest.objective
	reward_label.text = "Reward: " + str(quest.reward)
	progress_bar.max_value = quest.goal
	progress_bar.value = quest.progress

func update_progress(value: int):
	quest.progress = clamp(value, 0, quest.goal)
	update_display()
