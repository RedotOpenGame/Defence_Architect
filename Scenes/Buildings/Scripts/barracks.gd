extends CharacterBody2D

var health = 120

enum ACTIONS{AUTOTRAIN}

var unit_selection = ["sworder", "archer", "wizard"]


@onready var ally_keeper = get_tree().get_first_node_in_group("Ally_storage")
@onready var ui = get_tree().get_first_node_in_group("UI")
@onready var marker = $Marker2D
@onready var spawnpoint: Marker2D = $Spawnpoint
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
	if unit_wait_list.size() > 0:
		$Sprite2D2.modulate = Color.DARK_RED
	if timer.paused:
		$Sprite2D2.modulate = Color.YELLOW
	if unit_wait_list.size() > 0 and !making_a_unit:
		var unit_id = unit_wait_list[0]
		var unit_data = Defins.UNIT_DEFINITIONS[unit_id]
		if Gameplay.resource >= unit_data.cost:
			making_a_unit = true
			if timer.is_stopped():
				timer.start(unit_data.train_time)

	if unit_wait_list.size() == 0:
		$Sprite2D2.modulate = Color.WHITE
	if Input.is_action_just_pressed("right_mouse_click_and_shift") and selected:
		marker.global_position = get_global_mouse_position()

func _on_warrior_list_item_clicked(index: int, at_position: Vector2, mouse_button_index: int) -> void:
	if mouse_button_index == 1:
		if index == 0 and Gameplay.resource >= 2:
			unit_wait_list.append("sworder")
			trained_unit_list.add_item("sworder")
		if index == 1 and Gameplay.resource >= 3:
			unit_wait_list.append("archer")
			trained_unit_list.add_item("archer")

func add_unit_to_training(unit_name:String) -> void:
	unit_wait_list.append(unit_name)
	trained_unit_list.add_item(unit_name)

func damage_func(amount, pierce:float = 0.0) -> void:
	health -= amount
	prog_bar.value = health
	if health <= 0:
		queue_free()


func check_area_overlaps() -> bool:

	return $PLACEMENT.get_overlapping_areas() == []


func _on_selection_mouse_entered() -> void:
	$Control.visible = true
	$Marker2D/Sprite2D.visible = true


func _on_selection_mouse_exited() -> void:
	if !selected:
		$Control.visible = false
		$Marker2D/Sprite2D.visible = false

func resume_training() -> bool:
	
	if timer.paused:
		timer.paused = false
		return false
	return true

func pause_training(id) -> void:
	if timer.is_stopped():
		return

	if timer.paused:
		# Second call — cancel the first occurrence of this type
		var unit_name = unit_selection[id]
		var index_in_queue = unit_wait_list.find(unit_name)
		if index_in_queue != -1:
			unit_wait_list.remove_at(index_in_queue)
			trained_unit_list.remove_item(index_in_queue)

			# If we removed the unit currently training (front of queue), abort it
			if index_in_queue == 0:
				timer.stop()
				making_a_unit = false
	else:
		# First call — just pause
		timer.paused = true

func _on_selection_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed:
			selected = !selected
			if selected:
				get_tree().get_first_node_in_group("UI").chosen_barracks = self
				get_tree().get_first_node_in_group("UI").selection(self)

				var train_units:GridContainer = ui.train_units
				var iteration:int = 0
				for i in unit_selection:
					train_units.get_child(iteration).get_child(0).text = i
					iteration += 1
				train_units.visible = true
			else:
				var train_units:GridContainer = ui.train_units
				train_units.visible = false


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


func share_actions() -> Array:
	return ["Autotrain"]

func action_given(id) -> void:
	if id == 0:
		is_autotraining = !is_autotraining

func _on_spawn_timeout() -> void:
	var unit_id = unit_wait_list[0]
	var unit_data = Defins.UNIT_DEFINITIONS[unit_id]
	if !is_instance_valid(self):
		return
	making_a_unit = false
	if !is_autotraining:
		unit_wait_list.remove_at(0)
		trained_unit_list.remove_item(0)
	var scene = unit_data.scene.instantiate()
	scene.global_position = spawnpoint.global_position + Vector2(randf_range(-10, 10), randf_range(-10, 10))
	scene.marked_position = marker.global_position
	ally_keeper.add_child(scene)
	Gameplay.resource -= unit_data.cost
