extends CanvasLayer

@onready var name_label = $VBoxContainer/NameLabel
@onready var objective_label = $VBoxContainer/ObjectiveLabel
@onready var reward_label = $VBoxContainer/RewardLabel
@onready var progress_bar = $VBoxContainer/ProgressBar

var quest: Quest
var fixed_goal: int  # Store the effective goal (quest.goal + start_value) once

func set_quest(new_quest: Quest):
	quest = new_quest
	# Only set start_value and fixed_goal if not already set
	if quest.start_value == 0:  # Assuming 0 means uninitialized
		update_quest_data()
		fixed_goal = quest.goal + quest.start_value
		# Optionally save start_value to database for persistence
		# DatabaseManager.save_quest_start_value(quest.id, quest.start_value)
	update_display()
	print("Quest set:", quest.name, "Start value:", quest.start_value, "Fixed goal:", fixed_goal)

func update_quest_data():
	# Get fish counts from the database
	var counts = DatabaseManager.get_fish_counts()

	if quest.use_total_fish:
		# Calculate total fish caught across all columns
		var total_fish = 0
		for value in counts.values():
			total_fish += value  # Sum of all fish counts

		# Only set start_value if it’s not already set
		if quest.start_value == 0:
			quest.start_value = total_fish
			print("Initial start value set to:", quest.start_value)

func update_display():
	# Update labels and progress bar display
	name_label.text = "Quest: " + quest.name
	objective_label.text = "Objective: " + quest.objective
	reward_label.text = "Reward: " + str(quest.reward)
	progress_bar.max_value = quest.goal  # Max value is the original quest goal
	progress_bar.value = quest.progress  # Current progress

func update_progress(value: int):
	# Update the progress value and clamp it within the range [0, goal]
	quest.progress = clamp(value, 0, quest.goal)
	update_display()  # Refresh display with updated progress

	# Check if the quest is complete
	if quest.is_complete():
		print("QUEST COMPLETE! Reward:", quest.reward)
		DatabaseManager.increase_coins(quest.reward)

func update_from_db(fish_column: String):
	var fish_counts = DatabaseManager.get_fish_counts()
	print("Fish counts from DB:", fish_counts)  # Debug

	if quest.use_total_fish:
		var total = 0
		for value in fish_counts.values():
			total += value
		# Calculate progress as the difference from start_value
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
