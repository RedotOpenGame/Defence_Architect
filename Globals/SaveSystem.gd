extends Node

const FILE_NAME = "user://save_file.json" 

func save_game() -> void:
	var contents:Dictionary = {
		"eternal_resource":Gameplay.eternal_resource,
		"bought_upgrades":Gameplay.bought_upgrades
	}
	var json_string = JSON.stringify(contents)
	var file_access := FileAccess.open(FILE_NAME, FileAccess.WRITE)
	if not file_access:
		print("An error happened while saving data: ", FileAccess.get_open_error())
		return

	file_access.store_line(json_string)
	file_access.close()

func load_game() -> void:
	loader(FILE_NAME)

func loader(file):
	if not FileAccess.file_exists(file):
		return
	var file_access := FileAccess.open(file, FileAccess.READ)
	var json_string := file_access.get_line()
	file_access.close()

	var json := JSON.new()
	var error := json.parse(json_string)
	if error:
		printerr("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
		return
	# We saved a dictionary, lets assume is a dictionary
	var data:Dictionary = json.data
	if data.get("eternal_resource") != null:
		Gameplay.eternal_resource = data["eternal_resource"]
	if data.get("bought_upgrades") != null:
		Gameplay.bought_upgrades = data["bought_upgrades"]
	
	Gameplay.count_all_bought_upgrades()

func delete_save_data() -> void:
	var contents:Dictionary = {
		"eternal_resource":0,
		"bought_upgrades":{}
	}
	var json_string = JSON.stringify(contents)
	var file_access := FileAccess.open(FILE_NAME, FileAccess.WRITE)
	if not file_access:
		print("An error happened while saving data: ", FileAccess.get_open_error())
		return

	file_access.store_line(json_string)
	file_access.close()
