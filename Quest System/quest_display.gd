extends CanvasLayer

@onready var name_label = $VBoxContainer/NameLabel
@onready var objective_label = $VBoxContainer/ObjectiveLabel
@onready var reward_label = $VBoxContainer/RewardLabel
@onready var progress_bar = $VBoxContainer/ProgressBar

var quest: Quest
var fixed_goal: int
var available_quests: Array = []
var current_quest_index: int = 0

func _ready():
	available_quests = load_available_quests()
	if available_quests.is_empty():
		hide_gui()
	else:
		set_next_quest()
		#update_from_db(quest.fish_column)
		#update_from_db(quest.name)

func load_available_quests() -> Array:
	var quests = []
	var quest1 = Quest.new()
	quest1.id = 1
	quest1.name = "Fang Fisk"
	quest1.objective = "Fang 10 Fisk"
	quest1.goal = 10
	quest1.reward = 10
	quest1.use_total_fish = true
	quests.append(quest1)

	var quest2 = Quest.new()
	quest2.id = 2
	quest2.name = "Fang Laks"
	quest2.objective = "Fang 5 Laks"
	quest2.goal = 5
	quest2.reward = 50
	quest2.use_total_fish = false
	quest2.fish_column = "laks"
	quests.append(quest2)

	var quest3 = Quest.new()
	quest3.id = 3
	quest3.name = "Fang Fisk"
	quest3.objective = "Fang 20 fisk"
	quest3.goal = 20
	quest3.reward = 20
	quest3.use_total_fish = true
	quests.append(quest3)

	return quests

func set_next_quest():
	while current_quest_index < available_quests.size():
		var potential_quest = available_quests[current_quest_index]
		var quest_data = DatabaseManager.load_quest_data(potential_quest.id)
		if quest_data["is_completed"] == 0:
			set_quest(potential_quest)
			show_gui()
			return
		current_quest_index += 1

	# No available quests left
	quest = null
	hide_gui()

func set_quest(new_quest: Quest):
	quest = new_quest
	var quest_data = DatabaseManager.load_quest_data(quest.id)
	quest.start_value = quest_data["start_value"]
	quest.progress = quest_data["progress"]

	if quest.start_value == 0:
		update_quest_data()
		fixed_goal = quest.goal + quest.start_value
		DatabaseManager.save_quest_data(quest.id, quest.name, quest.objective, quest.start_value, quest.progress, false)
	else:
		fixed_goal = quest.goal + quest.start_value

	if quest_data["is_completed"] == 1:
		reward_label.text = "Reward: Claimed"
		reward_label.modulate = Color(0.5, 0.5, 0.5)
	else:
		update_display()

	print("Quest set:", quest.name, " Start value:", quest.start_value, " Fixed goal:", fixed_goal)

	update_from_db(quest.fish_column if not quest.use_total_fish else "")

func update_quest_data():
	var counts = DatabaseManager.get_fish_counts()
	if quest.use_total_fish:
		var total_fish = 0
		for value in counts.values():
			total_fish += value
		if quest.start_value == 0:
			quest.start_value = total_fish
			print("Initial start value set to:", quest.start_value)
			DatabaseManager.save_quest_data(quest.id, quest.name, quest.objective, quest.start_value, quest.progress, false)
			update_from_db(quest.name)
	else:
		if quest.fish_column in counts and quest.start_value == 0:
			quest.start_value = counts[quest.fish_column]
			print("Initial start value for", quest.fish_column, "set to:", quest.start_value)
			DatabaseManager.save_quest_data(quest.id, quest.name, quest.objective, quest.start_value, quest.progress, false)
			update_from_db(quest.fish_column)

func update_display():
	name_label.text = "Quest: " + quest.name
	objective_label.text = "Objective: " + quest.objective
	reward_label.text = "Reward: " + str(quest.reward)
	progress_bar.max_value = quest.goal
	progress_bar.value = quest.progress

func update_progress(value: int):
	if quest == null:
		print("No active quest. Skipping progress update.")
		return

	quest.progress = clamp(value, 0, quest.goal)
	update_display()

	var quest_data = DatabaseManager.load_quest_data(quest.id)
	DatabaseManager.save_quest_data(quest.id, quest.name, quest.objective, quest.start_value, quest.progress, false)

	if quest.is_complete() and quest_data["is_completed"] == 0:
		print("QUEST COMPLETE! Reward:", quest.reward)
		DatabaseManager.increase_coins(quest.reward)
		DatabaseManager.save_quest_data(quest.id, quest.name, quest.objective, quest.start_value, quest.progress, 1)
		reward_label.text = "Reward: Claimed"
		reward_label.modulate = Color(0.5, 0.5, 0.5)
		current_quest_index += 1
		set_next_quest()

func update_from_db(fish_column: String):
	if quest == null:
		print("No active quest. Skipping update.")
		return

	var fish_counts = DatabaseManager.get_fish_counts()
	print("Fish counts from DB:", fish_counts)

	if quest.use_total_fish:
		var total = 0
		for value in fish_counts.values():
			total += value
		var new_progress = total - quest.start_value
		print("Updating progress (total fish):", new_progress, "Total:", total, "Start value:", quest.start_value)
		update_progress(new_progress)
	else:
		if fish_column in fish_counts:
			var new_progress = fish_counts[fish_column] - quest.start_value
			print("Updating progress (specific fish):", new_progress)
			update_progress(new_progress)
		else:
			print("Fish column '%s' not found in database!" % fish_column)

func show_gui():
	visible = true

func hide_gui():
	visible = false
