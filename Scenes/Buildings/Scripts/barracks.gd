extends CharacterBody2D

var health = 120

var sworder_scene = preload("res://Scenes/Entities/Allies/ally_sworder.tscn")
var archer_scene = preload("res://Scenes/Entities/Allies/ally_archer_v_2.tscn")
@onready var ally_keeper = get_tree().get_first_node_in_group("Ally_storage")
@onready var marker = $Marker2D
@onready var trained_unit_list = $Control/PreparingWarriors
@onready var train_bar = $Control/ProgressBar
@onready var timer = $Spawn
var unit_wait_list:Array = []
var making_a_unit:bool = false
var selected:bool = false
var is_autotraining:bool = false

var unit_train_time:float = 2.5

@onready var prog_bar = $ProgressBar

func _ready() -> void:
	prog_bar.max_value = health
	prog_bar.value = health
	$Control.visible = false
	unit_train_time /= Gameplay.barracks_train_speed
	train_bar.max_value = unit_train_time
	$Control/Upgrade.visible = "barracks1" in Gameplay.owned_building_upgrades

func _process(delta: float) -> void:
	train_bar.value = timer.wait_time - timer.time_left
	if unit_wait_list.size() > 0 and !making_a_unit:
		$Sprite2D2.modulate = Color.DARK_GOLDENROD
		if unit_wait_list[0] == "sworder" and Gameplay.resource >= 2:
			making_a_unit = true
			timer.start(unit_train_time)
			await timer.timeout
			making_a_unit = false
			if !is_autotraining:
				unit_wait_list.remove_at(0)
				trained_unit_list.remove_item(0)
			var scene = sworder_scene.instantiate()
			scene.global_position = marker.global_position
			ally_keeper.add_child(scene)
			Gameplay.resource -= 2
		elif unit_wait_list[0] == "archer" and Gameplay.resource >= 3:
			making_a_unit = true
			timer.start(unit_train_time)
			await timer.timeout
			making_a_unit = false
			if !is_autotraining:
				unit_wait_list.remove_at(0)
				trained_unit_list.remove_item(0)
			var scene = archer_scene.instantiate()
			scene.global_position = marker.global_position
			ally_keeper.add_child(scene)
			Gameplay.resource -= 3
	if unit_wait_list.size() == 0:
		$Sprite2D2.modulate = Color.WHITE

func _on_warrior_list_item_clicked(index: int, at_position: Vector2, mouse_button_index: int) -> void:
	if mouse_button_index == 1:
		if index == 0 and Gameplay.resource >= 2:
			unit_wait_list.append("sworder")
			trained_unit_list.add_item("sworder")
		if index == 1 and Gameplay.resource >= 3:
			unit_wait_list.append("archer")
			trained_unit_list.add_item("archer")

func damage_func(amount) -> void:
	health -= amount
	prog_bar.value = health
	if health <= 0:
		queue_free()


func check_area_overlaps() -> bool:

	return $PLACEMENT.get_overlapping_areas() == []


func _on_selection_mouse_entered() -> void:
	$Control.visible = true


func _on_selection_mouse_exited() -> void:
	if !selected:
		$Control.visible = false


func _on_selection_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed:
			selected = !selected
			#print(selected)


func _on_upgrade_pressed() -> void:
	if Gameplay.resource >= 10:
		Gameplay.resource -= 10
		$Control/Upgrade.visible = false
		$Control/AutoTraining.visible = true


func _on_auto_training_toggled(toggled_on: bool) -> void:
	is_autotraining = toggled_on
	if toggled_on:
		$Control/AutoTraining.text = "Auto-train:
ON"
	else:
		$Control/AutoTraining.text = "Auto-train:
OFF"
