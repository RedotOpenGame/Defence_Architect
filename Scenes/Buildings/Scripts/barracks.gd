extends CharacterBody2D

var health: int = 120

@onready var selection: Control = $Selection

@onready var prog_bar: ProgressBar = $ProgressBar
@onready var marker: Marker2D = $Marker2D
@onready var train_bar: ProgressBar = $Control/ProgressBar
@onready var preparing_list = $Control/PreparingWarriors
@onready var trainer: TrainerComponent = $TrainerComponent
@onready var upgrader: UpgradeComponent = $UpgradeComponent

var selected: bool = false

func _ready() -> void:
	prog_bar.max_value = health
	prog_bar.value = health
	$Control.visible = false

	trainer.unlocked_units = ["sworder", "archer", "wizard"]
	trainer.autotrain_available = true
	trainer.queue_changed.connect(_refresh_hover_list)

func _process(_delta: float) -> void:
	train_bar.value = _train_progress_pixels()
	if trainer.unit_wait_list.size() > 0:
		$Sprite2D2.modulate = Color.DARK_RED
	if trainer._timer.paused:
		$Sprite2D2.modulate = Color.YELLOW
	if trainer.unit_wait_list.size() == 0:
		$Sprite2D2.modulate = Color.WHITE

	if Input.is_action_just_pressed("right_mouse_click_and_shift") and selected:
		marker.global_position = get_global_mouse_position()

func _train_progress_pixels() -> float:
	var t = trainer._timer
	if t.is_stopped():
		return 0.0
	return t.wait_time - t.time_left

func _refresh_hover_list() -> void:
	preparing_list.clear()
	for unit_name in trainer.unit_wait_list:
		preparing_list.add_item(unit_name)

func damage_func(amount: float, _pierce: float = 0.0) -> void:
	health -= amount
	prog_bar.value = health
	if health <= 0:
		queue_free()

func check_area_overlaps() -> bool:
	return $PLACEMENT.get_overlapping_areas() == []

func _on_selection_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == 1 and event.pressed:
		selected = not selected
		var ui = get_tree().get_first_node_in_group("UI")
		if selected:
			ui.on_building_selected(self)
		else:
			ui.on_building_deselected()

func ui_cleanup() -> void:
	_on_selection_mouse_exited()

func _on_selection_mouse_entered() -> void:
	$Control.visible = true
	$Marker2D/Sprite2D.visible = true

func _on_selection_mouse_exited() -> void:
	if not selected:
		$Control.visible = false
		$Marker2D/Sprite2D.visible = false

func _on_spawn_timeout() -> void:
	trainer.on_spawn_timeout()

func _on_placement_body_entered(_body: Node2D) -> void:
	pass

func _on_placement_body_exited(_body: Node2D) -> void:
	pass
