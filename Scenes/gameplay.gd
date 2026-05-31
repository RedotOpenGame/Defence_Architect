extends Node2D


@onready var showcase = $Showcase
@onready var prog_bar: ProgressBar = $HyperUI/ProgressBar
@onready var resources_label = $UI/Resources
@onready var wave_label: Label = $HyperUI/Wave

@onready var enemy_spawn_pos = $Enemyspawnpos
@onready var enemy_enti = $Entities/Hostiles
@onready var ally_enti = $Entities/Allies



const max_untill_another_attack:float = 30
var waves_working:bool = true #meant to stop waves for debug purposes.
var untill_another_attack:float = max_untill_another_attack
var curr_wave:int = 0
var player_resources = 20

var waiting_upgrades:int = 0

var enemy_dictionary:Dictionary = {
	#"example":[preload(path/to/scene.tscn), int(spawn_cost), int(spawns at/after wave)]
	"sworder":[preload("res://Scenes/Entities/Enemies/enemy_sworder.tscn"), 1, 1, 1.0],
	"archer":[preload("res://Scenes/Entities/Enemies/enemy_archer.tscn"), 1, 3, 0.5],
	"grenader":[preload("res://Scenes/Entities/Enemies/enemy_grenader.tscn"), 2, 5, 0.2],
	"helicopter":[preload("res://Scenes/Entities/Enemies/enemy_helicopter.tscn"), 6, 7, 0.05],
	"tank":[preload("res://Scenes/Entities/Enemies/enemy_armored.tscn"), 6, 10, 0.02]
}

var building_scenes:Dictionary = {
	"barracks":{"scene":preload("res://Scenes/Buildings/barracks.tscn"), "cost":6},
	"farm":{"scene":preload("res://Scenes/Buildings/farm.tscn"), "cost":6},
	"defence turret":{"scene":preload("res://Scenes/Buildings/defence_turret.tscn"), "cost":10},
	"factory":{"scene":preload("res://Scenes/Buildings/factory.tscn"), "cost":10},
}

var build_mode:bool = false
var building_cost:int
var selected_building
var building_to_spawn
var eternal_res_reward:int = 0

func _ready() -> void:
	prog_bar.max_value = max_untill_another_attack
	prog_bar.value = max_untill_another_attack

	
func _process(delta: float) -> void:
	untill_another_attack -= delta
	prog_bar.value = untill_another_attack
	resources_label.text = str("Resources: ", Gameplay.resource)
	wave_label.text = str("Wave: ", curr_wave)
	if untill_another_attack <= 0 and waves_working:
		curr_wave += 1
		if curr_wave % 3 == 0:
			Gameplay.eternal_resource += 1 * floor(curr_wave / 3)
		untill_another_attack = max_untill_another_attack
		for i in get_tree().get_nodes_in_group("Farm"):
			i.give_money()
		Gameplay.resource += curr_wave
		var wave_budget = ceil(curr_wave ** 1.3)

		# Build list of available units: [scene, cost, weight]
		var available_units: Array = []
		for key in enemy_dictionary:
			var data = enemy_dictionary[key]
			if data[2] <= curr_wave:                # wave requirement
				available_units.append([data[0], data[1], data[3]])  # scene, cost, weight

		#if available_units.is_empty():
			#return

		# Total weight for the current wave's pool
		var total_weight := 0.0
		for unit in available_units:
			total_weight += unit[2]

		# Spawn loop
		while wave_budget > 0:
			# Weighted random pick
			var r := randf() * total_weight
			var cumulative := 0.0
			var chosen = available_units[0]  # fallback
			for unit in available_units:
				cumulative += unit[2]
				if r <= cumulative:
					chosen = unit
					break

			# Only spawn if budget allows
			if wave_budget >= chosen[1]:
				wave_budget -= chosen[1]
				var s = chosen[0].instantiate()
				s.position = enemy_spawn_pos.position + Vector2(randf_range(-300,300), randf_range(-300,300))
				enemy_enti.add_child(s)
			else:
				break   # can't afford any more
	
	if selected_building:
		selected_building.global_position = lerp(selected_building.global_position, get_global_mouse_position(), 10 * delta)
		#selected_building.process_mode = Node.PROCESS_MODE_DISABLED
		selected_building.collision_layer = 512
		selected_building.collision_mask = 512
		selected_building.modulate = Color(1,1,1,0.4)
		if selected_building not in showcase.get_children():
			showcase.add_child(selected_building)

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
			showcase.remove_child(selected_building)
			building_to_spawn = null
			selected_building = null
			build_mode = false



func spawn_enemies() -> void:
	pass

func _on_building_list_item_clicked(index: int, at_position: Vector2, mouse_button_index: int) -> void:
	if mouse_button_index == 1:
		if is_instance_valid(selected_building):
			selected_building.queue_free()
		var new_building = building_scenes[$UI/BuildingList.get_item_text(index)]["scene"]
		if Gameplay.resource >= building_scenes[$UI/BuildingList.get_item_text(index)]["cost"]:
			building_cost = building_scenes[$UI/BuildingList.get_item_text(index)]["cost"]
			selected_building = new_building.instantiate()
			building_to_spawn = new_building
			build_mode = false


func spawn_building():
	var building = building_to_spawn.instantiate()
	building.global_position = get_global_mouse_position()

	ally_enti.add_child(building)



func _on_disselectworkers_pressed() -> void:
	for i in get_tree().get_nodes_in_group("Ally"):
		if "is_selected" in i:
			i.is_selected(false)


func _on_skip_pressed() -> void:
	untill_another_attack = 0

func _on_check_box_toggled(toggled_on: bool) -> void:
	$PlayerCamera.moving_using_cursor = !toggled_on




func _on_building_list_mouse_exited() -> void:
	$UI/BuildingCost.text = str("Cost: ")


func _on_surrender_pressed() -> void:
	SaveSystem.save_game()
	get_tree().change_scene_to_file("res://Scenes/menus/post_death_shop.tscn")


func _on_getexp_pressed() -> void:
	$Entities/Allies/Player_Actor.get_exp(200)


func _on_player_actor_leveled_up() -> void:
	waiting_upgrades += 1




func _on_kill_all_enemies_pressed() -> void:
	for i in enemy_enti.get_children():
		i.queue_free()
