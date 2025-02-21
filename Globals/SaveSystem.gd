extends Node

const FILE_NAME = "user://save_file.json" 

func save_game() -> void:
	var contents:Dictionary = {
		"eternal_resource":Gameplay.eternal_resource,
		"available_buildings":Gameplay.owned_buildings,
		"available_building_upgrades":Gameplay.owned_building_upgrades,
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
	if data.get("available_buildings") != null:
		Gameplay.owned_buildings = data["available_buildings"]
	if data.get("available_building_upgrades") != null:
		Gameplay.owned_building_upgrades = data["available_building_upgrades"]
