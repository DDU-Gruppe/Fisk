extends Node

# Use a static variable so its value persists even if _init() is called more than once.
static var number_incremented: bool = false

var db

func _init():
	# (Optional) Print a message to see if _init() is running again.
	print("DatabaseManager _init() called.")

	# Define the folder in user:// where the database will be stored.
	var target_folder = "user://my_db_folder"
	var dir = DirAccess.open("user://")
	if dir:
		if not dir.dir_exists("my_db_folder"):
			var err = dir.make_dir("my_db_folder")
			if err != OK:
				print("Error creating folder 'my_db_folder': ", err)
			else:
				print("Folder created: ", target_folder)
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
		if src_file:
			var dst_file = FileAccess.open(target_db_path, FileAccess.WRITE)
			if dst_file:
				dst_file.store_buffer(src_file.get_buffer(src_file.get_length()))
				src_file.close()
				dst_file.close()
				print("Database copied successfully.")
			else:
				print("Failed to create destination DB file: ", target_db_path)
		else:
			print("Failed to open source DB file: res://db/test.db")
	else:
		print("Database already exists at: ", target_db_path)
	
	# Instantiate the SQLite object (assuming the plugin registers a global class named "SQLite").
	db = SQLite.new()
	db.path = target_db_path
	if db.open_db() == false:
		print("Failed to open database at: ", target_db_path)
	else:
		print("Database opened successfully at: ", target_db_path)
		
		# Increment the "number" column only if it hasn't been incremented yet.
		if not number_incremented:
			if db.query("UPDATE data SET number = COALESCE(number, 0) + 1") == false:
				print("Failed to increment number:", db.error_message)
			else:
				print("Number incremented successfully.")
			number_incremented = true
		
		# Optionally, query the new number and print it.
		if db.query("SELECT number FROM data") == false:
			print("Failed to query number:", db.error_message)
		else:
			for row in db.query_result:
				print("Current number is:", row["number"])

func get_data() -> Array:
	if db.query("SELECT status FROM data") == false:
		print("SQL Query failed:", db.error_message)
		return []
	return db.query_result
