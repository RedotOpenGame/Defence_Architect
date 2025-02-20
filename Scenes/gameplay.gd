extends Node2D

@onready var showcase = $Showcase
@onready var prog_bar = $UI/ProgressBar
@onready var resources_label = $UI/Resources
@onready var wave_label = $UI/Wave
@onready var enemy_spawn_pos = $Enemyspawnpos
@onready var enemy_enti = $Entities/Hostiles
@onready var ally_enti = $Entities/Allies

const max_untill_another_attack:float = 30
var waves_working:bool = true #meant to stop waves for debug purposes.
var untill_another_attack:float = max_untill_another_attack
var curr_wave = 0
var player_resources = 20

var enemy_sworder_scene = preload("res://Scenes/Entities/Enemies/enemy_sworder.tscn")


var barracks_scene = preload("res://Scenes/Buildings/barracks.tscn")
var farm_scene = preload("res://Scenes/Buildings/farm.tscn")

var build_mode:bool = false
var building_cost:int
var selected_building
var building_to_spawn


func _ready() -> void:
	prog_bar.max_value = max_untill_another_attack
	prog_bar.value = max_untill_another_attack
	resources_label.text = str("Resources: ", Gameplay.resource)
	
func _process(delta: float) -> void:
	untill_another_attack -= delta
	prog_bar.value = untill_another_attack
	resources_label.text = str("Resources: ", Gameplay.resource)
	wave_label.text = str("Wave: ", curr_wave)
	if untill_another_attack <= 0 and waves_working:
		curr_wave += 1
		untill_another_attack = max_untill_another_attack
		for i in get_tree().get_nodes_in_group("Farm"):
			i.give_money()
		Gameplay.resource += curr_wave
		for i in range(ceil((curr_wave) ** 1.3)):
			var scene = enemy_sworder_scene.instantiate()
			scene.position = enemy_spawn_pos.position + Vector2(randf_range(-300, 300), randf_range(-300, 300))
			enemy_enti.add_child(scene)
	
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


func _on_building_list_item_clicked(index: int, at_position: Vector2, mouse_button_index: int) -> void:
	if mouse_button_index == 1:
		if is_instance_valid(selected_building):
			selected_building.queue_free()
		if index == 0 and Gameplay.resource >= 6:
			building_cost = 6
			selected_building = barracks_scene.instantiate()
			building_to_spawn = barracks_scene
			build_mode = false
		if index == 1 and Gameplay.resource >= 6:
			building_cost = 6
			selected_building = farm_scene.instantiate()
			building_to_spawn = farm_scene
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
