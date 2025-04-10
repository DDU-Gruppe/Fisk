extends Node

static var instance_initialized: bool = false
static var number_incremented: bool = false

var db

func _init():
	# Prevent duplicate initialization.
	if instance_initialized:
		return
	instance_initialized = true

	var target_folder = "user://my_db_folder"
	var dir = DirAccess.open("user://")
	if dir:
		if not dir.dir_exists("my_db_folder"):
			var err = dir.make_dir("my_db_folder")
			if err == OK:
				print("Folder created: ", target_folder)
			else:
				print("Error creating folder 'my_db_folder': ", err)
	else:
		print("Error: Cannot open user:// directory.")

	var target_db_path = target_folder + "/test.db"

	if not FileAccess.file_exists(target_db_path):
		print("Copying database to: ", target_db_path)
		var src_file = FileAccess.open("res://db/test.db", FileAccess.READ)
		if src_file:
			var dst_file = FileAccess.open(target_db_path, FileAccess.WRITE)
			if dst_file:
				dst_file.store_buffer(src_file.get_buffer(src_file.get_length()))
				src_file.close()
				dst_file.close()
			else:
				print("Failed to create destination DB file: ", target_db_path)
		else:
			print("Failed to open source DB file: res://db/test.db")

	db = SQLite.new()
	db.path = target_db_path
	if db.open_db():

		ensure_inventory_row()

		if not number_incremented:
			if db.query("UPDATE data SET number = COALESCE(number, 0) + 1"):
				print("")
			else:
				print("Failed to increment number:", db.error_message)
			number_incremented = true

		if db.query("SELECT number FROM data"):
			for row in db.query_result:
				print("Tries:", row["number"])
				if row["number"]%10 == 0:
					print("It really isn't working huh?")
		else:
			print("Failed to query number:", db.error_message)
	else:
		print("Failed to open database at: ", target_db_path)

func ensure_inventory_row() -> void:
	# Ensure there's at least one row in the Inventory table.
	if db.query("SELECT COUNT(*) AS cnt FROM Inventory") == false:
		print("Failed to count Inventory rows:", db.error_message)
	else:
		var cnt = db.query_result[0]["cnt"]
		if cnt == 0:
			print("No rows in Inventory. Inserting default row.")
			# Insert into the correct columns: laks, torsk, bluefish, tun.
			if db.query("INSERT INTO Inventory (laks, torsk, bluefish, tun, coin) VALUES (0, 0, 0, 0, 0)") == false:
				print("Failed to insert default Inventory row:", db.error_message)
			else:
				print("Default Inventory row inserted.")

func get_data() -> Array:
	if db.query("SELECT * FROM Inventory LIMIT 1") == false:
		print("SQL Query failed in get_data():", db.error_message)
		return []
	print("Inventory result:", db.query_result)
	return db.query_result

func get_fish_counts() -> Dictionary:
	# Query for laks, torsk, bluefish, tun.
	if db.query("SELECT laks, torsk, bluefish, tun FROM Inventory LIMIT 1") == false:
		print("SQL Query failed in get_fish_counts():", db.error_message)
		return {}
	return db.query_result[0]

func increase_fish(fish_column: String, amount: int = 1) -> void:
	var query = "UPDATE Inventory SET %s = COALESCE(%s, 0) + %d" % [fish_column, fish_column, amount]
	print("Running query:", query)
	if db.query(query) == false:
		print("Failed to update fish count:", db.error_message)
	else:
		print("Fish count updated: +%d to %s" % [amount, fish_column])
		if db.query("SELECT * FROM Inventory LIMIT 1"):
			for row in db.query_result:
				print("Inventory after update:", row)
		else:
			print("Failed to re-query Inventory after update:", db.error_message)

func increase_coins(amount: int) -> void:
	var query = "UPDATE Inventory SET coin = COALESCE(coin, 0) + %d" % amount
	if db.query(query) == false:
		print("Failed to update coins:", db.error_message)
	else:
		# Re-query coin count.
		if db.query("SELECT coin AS new_count FROM Inventory LIMIT 1") == false:
			print("Failed to re-query coin count:", db.error_message)
		else:
			var new_count = db.query_result[0]["new_count"]
			print("New coin count is:", new_count)

func _on_fishing_win(column_name: String) -> void:
	print("Win signal received for column:", column_name)
	increase_fish(column_name, 1)

	if has_node("QuestDisplay"):
		var quest_display = $QuestDisplay
		if quest_display.quest:
			if quest_display.quest.use_total_fish or quest_display.quest.fish_column == column_name:
				quest_display.update_from_db(column_name)
