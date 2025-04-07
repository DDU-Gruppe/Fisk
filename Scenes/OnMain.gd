extends Node

# Static flags to persist state even if the script is reloaded.
static var instance_initialized: bool = false
static var number_incremented: bool = false

var db

func _init():
	# Print a message with the instance ID for debugging.
	print("DatabaseManager _init() called. Instance ID:", get_instance_id())
	
	# If already initialized, exit early.
	if instance_initialized:
		return
	instance_initialized = true

	# Define the folder in user:// where the database will be stored.
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
			print("Folder already exists: ", target_folder)
	else:
		print("Error: Cannot open user:// directory.")
	
	# Define the target database path.
	var target_db_path = target_folder + "/test.db"
	
	# Copy the database from res://db/test.db if it doesn't exist in user://.
	if not FileAccess.file_exists(target_db_path):
		print("Copying database to: ", target_db_path)
		var src_file = FileAccess.open("res://db/test.db", FileAccess.READ)
		var dst_file = FileAccess.open(target_db_path, FileAccess.WRITE)
		dst_file.store_buffer(src_file.get_buffer(src_file.get_length()))
		src_file.close()
		dst_file.close()
		print("Database copied successfully.")
	else:
		print("Database already exists at: ", target_db_path)
	
	# Instantiate the SQLite object (assuming the plugin registers a global class named "SQLite").
	db = SQLite.new()
	db.path = target_db_path
	if db.open_db():
		print("Database opened successfully at: ", target_db_path)
		
		# Increment the "number" column only if not already done.
		if not number_incremented:
			if db.query("UPDATE data SET number = COALESCE(number, 0) + 1"):
				print("Number incremented successfully.")
			else:
				print("❌ Failed to increment number:", db.error_message)
			number_incremented = true
		
		# Query and print the current number.
		if db.query("SELECT number FROM data"):
			for row in db.query_result:
				print("Current number is:", row["number"])
		else:
			print("Failed to query number:", db.error_message)
	else:
		print("❌ Failed to open database at: ", target_db_path)

func get_data() -> Array:
	if db.query("SELECT * FROM Inventory LIMIT 1") == false:
		print("❌ SQL Query failed in get_data():", db.error_message)
		return []
	print("📦 Inventory result:", db.query_result)
	return db.query_result

func increase_fish(fish_column: String, amount: int = 1) -> void:
	var query = "UPDATE Inventory SET %s = COALESCE(%s, 0) + %d" % [fish_column, fish_column, amount]
	print("⚙️ Running query:", query)
	if db.query(query) == false:
		print("❌ Failed to update fish count:", db.error_message)
	else:
		print("✅ Fish count updated: +%d to %s" % [amount, fish_column])
		# Confirm the update by re-querying the Inventory table.
		if db.query("SELECT * FROM Inventory LIMIT 1"):
			for row in db.query_result:
				print("📦 Inventory after update:", row)
		else:
			print("❌ Failed to re-query Inventory after update:", db.error_message)

func _input(event):
	if event.is_action_pressed("toggle_boat_scene"):
		get_tree().change_scene_to_file("res://Scenes/OnBoat.tscn")
	if event.is_action_pressed("start_fishing"):
		get_tree().change_scene_to_file("res://Scenes/fishing_minigame.tscn")
