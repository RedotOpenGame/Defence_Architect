extends CanvasLayer

@onready var train_units: GridContainer = $TrainUnits
@onready var resources_label: Label = $Resources
@onready var building_list: ItemList = $BuildingList
@onready var cost_label: Label = $BuildingCost
@onready var trainformation: RichTextLabel = $Trainformation
@onready var actions: VBoxContainer = $Actions


@onready var ally_enti = get_tree().get_first_node_in_group("Ally_storage")


var build_mode:bool = false
var building_cost:int
var selected_building
var building_to_spawn
var eternal_res_reward:int = 0

var chosen_barracks: Node

func _ready() -> void:
	resources_label.text = str("Resources: ", Gameplay.resource)
	
	for i in Gameplay.owned_buildings:
		building_list.add_item(i)

func count_units(wait_list: Array) -> Dictionary:
	var counts := {}
	for unit_id in wait_list:
		counts[unit_id] = counts.get(unit_id, 0) + 1
	return counts

func format_queue_display(wait_list: Array, display_order: Array) -> String:
	var counts = count_units(wait_list)
	var lines := []
	for unit_id in display_order:
		if counts.get(unit_id, 0) > 0:
			lines.append("%s: %d" % [unit_id.capitalize(), counts[unit_id]])
	return "\n".join(lines)

func selection(building) -> void:
	var a:Array = building.share_actions()
	for i in actions.get_children():
		i.visible = false
	var iteration:int = 0
	for i in a:
		actions.get_child(iteration).visible = true
		actions.get_child(iteration).text = i
		iteration += 1
	
func _process(delta: float) -> void:
	if is_instance_valid(chosen_barracks):
		var iteration:int = 0
		var counter = count_units(chosen_barracks.unit_wait_list)
		for i in chosen_barracks.unit_selection: 
			for j in counter:
				train_units.get_child(iteration).get_child(1).text = "0"
				if i == j:
					train_units.get_child(iteration).get_child(1).text = str(counter[i])
					if i == chosen_barracks.unit_wait_list[0]:
						train_units.get_child(iteration).max_value = chosen_barracks.timer.wait_time
						train_units.get_child(iteration).value = chosen_barracks.timer.wait_time - chosen_barracks.timer.time_left
					break
			iteration += 1
		if chosen_barracks.unit_wait_list == []:
			for i in train_units.get_children():
				i.get_child(1).text = "0"
	
	if selected_building:
		selected_building.global_position = lerp(selected_building.global_position, ally_enti.get_global_mouse_position(), 10 * delta)
		#selected_building.process_mode = Node.PROCESS_MODE_DISABLED
		selected_building.collision_layer = 512
		selected_building.collision_mask = 512
		selected_building.modulate = Color(1,1,1,0.4)
		if selected_building not in ally_enti.get_children():
			ally_enti.add_child(selected_building)

		if Input.is_action_just_pressed("left_mouse_click"):
			
			if build_mode and Gameplay.resource >= building_cost: #need it so that it wouldn't instantly spawn when you press on an itemlist
				var collider = selected_building.check_area_overlaps()
				if !collider:
					#print("You can't place here!!!")
					pass
				else:
					spawn_building()
					Gameplay.resource -= building_cost
			build_mode = true
		if Input.is_action_just_pressed("right_mouse_click"):
			ally_enti.remove_child(selected_building)
			building_to_spawn = null
			selected_building = null
			build_mode = false

func _on_building_list_item_clicked(index: int, at_position: Vector2, mouse_button_index: int) -> void:
	if mouse_button_index == 1:
		if is_instance_valid(selected_building):
			selected_building.queue_free()
		var build_name = building_list.get_item_text(index)
		var new_building = Defins.BUILDING_DEFINITIONS[build_name]["scene"]
		if Gameplay.resource >= Defins.BUILDING_DEFINITIONS[build_name]["cost"]:
			building_cost = Defins.BUILDING_DEFINITIONS[build_name]["cost"]
			selected_building = new_building.instantiate()
			building_to_spawn = new_building
			build_mode = false

func _on_building_list_item_hovered(index: int) -> void:
	cost_label.text = str("Cost: ", Defins.BUILDING_DEFINITIONS[building_list.get_item_text(index)]["cost"])


func spawn_building():
	var building = building_to_spawn.instantiate()
	building.global_position = ally_enti.get_global_mouse_position()

	ally_enti.add_child(building)

func _on_unit_training_list_item_clicked(index: int, at_position: Vector2, mouse_button_index: int) -> void:
	if mouse_button_index == 1:
		
		var unit_name = train_units.get_item_text(index)
		chosen_barracks.add_unit_to_training(unit_name)


func gui_to_barracks(id, event:InputEvent) -> void:
	if !is_instance_valid(chosen_barracks):
		return
	if chosen_barracks.unit_selection.size() - 1 < id:
		return
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var unit_name = chosen_barracks.unit_selection[id]
			if chosen_barracks.resume_training():
				chosen_barracks.add_unit_to_training(unit_name)
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			var unit_name = chosen_barracks.unit_selection[id]
			chosen_barracks.pause_training(id)

func _on_texture_rect_gui_input(event: InputEvent) -> void:
	gui_to_barracks(0, event)


func _on_texture_rect_2_gui_input(event: InputEvent) -> void:
	gui_to_barracks(1, event)


func _on_texture_rect_3_gui_input(event: InputEvent) -> void:
	gui_to_barracks(2, event)


func _on_texture_rect_4_gui_input(event: InputEvent) -> void:
	gui_to_barracks(3, event)


func _on_texture_rect_5_gui_input(event: InputEvent) -> void:
	gui_to_barracks(4, event)


func _on_texture_rect_6_gui_input(event: InputEvent) -> void:
	gui_to_barracks(5, event)


func _on_building_list_mouse_exited() -> void:
	cost_label.text = "Cost: "

func show_train_info(id) -> void:
	if !is_instance_valid(chosen_barracks):
		return
	if chosen_barracks.unit_selection.size() - 1 < id:
		return
	var unit_name = chosen_barracks.unit_selection[id]
	trainformation.text = "
Cost: %s
Train time: %s" % [Defins.UNIT_DEFINITIONS[unit_name]["cost"], Defins.UNIT_DEFINITIONS[unit_name]["train_time"]]

func _on_texture_rect_mouse_entered() -> void:
	show_train_info(0)


func _on_texture_rect_mouse_exited() -> void:
	trainformation.text = ""


func _on_texture_rect_2_mouse_entered() -> void:
	show_train_info(1)


func _on_texture_rect_2_mouse_exited() -> void:
	trainformation.text = ""


func _on_texture_rect_3_mouse_entered() -> void:
	show_train_info(2)


func _on_texture_rect_3_mouse_exited() -> void:
	trainformation.text = ""


func _on_texture_rect_4_mouse_entered() -> void:
	show_train_info(3)


func _on_texture_rect_4_mouse_exited() -> void:
	trainformation.text = ""


func _on_texture_rect_5_mouse_entered() -> void:
	show_train_info(4)


func _on_texture_rect_5_mouse_exited() -> void:
	trainformation.text = ""


func _on_texture_rect_6_mouse_entered() -> void:
	show_train_info(5)


func _on_texture_rect_6_mouse_exited() -> void:
	trainformation.text = ""


func _on_surrender_pressed() -> void:
	SaveSystem.save_game()
	get_tree().change_scene_to_file("res://Scenes/menus/post_death_shop.tscn")


func _on_action_1_pressed() -> void:
	if !is_instance_valid(chosen_barracks):
		return
	chosen_barracks.action_given(0)
