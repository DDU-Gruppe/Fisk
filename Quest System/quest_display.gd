extends CanvasLayer

@onready var name_label = $VBoxContainer/NameLabel
@onready var objective_label = $VBoxContainer/ObjectiveLabel
@onready var reward_label = $VBoxContainer/RewardLabel
@onready var progress_bar = $VBoxContainer/ProgressBar

var quest: Quest

func set_quest(new_quest: Quest):
	quest = new_quest
	update_quest_data()
	update_display()

func update_quest_data():
	# Get fish counts from the database
	var counts = DatabaseManager.get_fish_counts()

	if quest.use_total_fish:
		# Calculate total fish caught across all columns
		var total_fish = 0
		for value in counts.values():
			total_fish += value  # Sum of all fish counts
		# Set the starting value and goal accordingly
		quest.start_value = total_fish
		quest.goal = quest.start_value + 20  # Set the goal as 20 more than the start value
	else:
		# Specific fish column (e.g., "laks", "torsk")
		quest.start_value = counts.get(quest.fish_column, 0)  # Fish count for specific column
		quest.goal = quest.start_value + 20  # Set the goal as 20 more than the start value

func update_display():
	# Update labels and progress bar display
	name_label.text = "Quest: " + quest.name
	objective_label.text = "Objective: " + quest.objective
	reward_label.text = "Reward: " + str(quest.reward)
	progress_bar.max_value = quest.goal  # Set max value to goal
	progress_bar.value = quest.progress  # Set current value to progress

func update_progress(value: int):
	# Update the progress value and clamp it within the range [0, goal]
	quest.progress = clamp(value, 0, quest.goal)
	update_display()  # Refresh display with updated progress

	# Check if the quest is complete
	if quest.is_complete():
		print("QUEST COMPLETE! Reward:", quest.reward)
		# TODO: Add reward logic here (XP, coins, etc.)

func update_from_db(fish_column: String):
	var fish_counts = DatabaseManager.get_fish_counts()

	if quest.use_total_fish:
		# Calculate total fish caught (across all columns)
		var total = 0
		for value in fish_counts.values():
			total += value
		# Update progress based on the total fish caught
		var new_progress = total - quest.start_value
		print("Updating progress (total fish):", new_progress)
		update_progress(new_progress)
	else:
		# If tracking one specific fish type
		if fish_column in fish_counts:
			var new_progress = fish_counts[fish_column] - quest.start_value
			print("Updating progress (specific fish):", new_progress)
			update_progress(new_progress)
		else:
			print("Fish column '%s' not found in database!" % fish_column)
