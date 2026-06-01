extends Node
class_name TrainerComponent

signal queue_changed

## Units available for training. Populated by the building on _ready;
## UpgradeComponent can append to this via apply_effect.
var unlocked_units: Array[String] = []

var unit_wait_list: Array[String] = []
var making_a_unit: bool = false
var is_autotraining: bool = false
var autotrain_available: bool = false

var _timer: Timer
var _spawnpoint: Marker2D
var _marker: Marker2D
var _ally_keeper: Node

func _ready() -> void:
	_ally_keeper = get_tree().get_first_node_in_group("Ally_storage")
	_timer = get_parent().get_node("Spawn")
	_spawnpoint = get_parent().get_node("Spawnpoint")
	_marker = get_parent().get_node("Marker2D")

func _process(_delta: float) -> void:
	if unit_wait_list.size() > 0 and not making_a_unit:
		var unit_id = unit_wait_list[0]
		var unit_data = Defins.UNIT_DEFINITIONS[unit_id]
		if Gameplay.resource >= unit_data.cost:
			making_a_unit = true
			if _timer.is_stopped():
				_timer.start(unit_data.train_time)

## Left-click: queue a unit (or unpause if currently paused).
func queue_unit(unit_name: String) -> void:
	if unit_name not in unlocked_units:
		return
	if _timer.paused:
		_timer.paused = false
		return
	unit_wait_list.append(unit_name)
	queue_changed.emit()

## Right-click: first press pauses, second press cancels the queued unit.
func cancel_unit(slot_index: int) -> void:
	if slot_index >= unlocked_units.size():
		return
	if _timer.is_stopped():
		return
	var unit_name = unlocked_units[slot_index]
	if _timer.paused:
		var idx = unit_wait_list.find(unit_name)
		if idx != -1:
			unit_wait_list.remove_at(idx)
			if idx == 0:
				_timer.stop()
				making_a_unit = false
			queue_changed.emit()
	else:
		_timer.paused = true

func toggle_autotrain() -> void:
	if not autotrain_available:
		return
	is_autotraining = not is_autotraining

## Called by the building's _on_spawn_timeout forwarding.
func on_spawn_timeout() -> void:
	if unit_wait_list.is_empty():
		return
	var unit_id = unit_wait_list[0]
	var unit_data = Defins.UNIT_DEFINITIONS[unit_id]
	making_a_unit = false
	if not is_autotraining:
		unit_wait_list.remove_at(0)
	var scene = unit_data.scene.instantiate()
	scene.global_position = _spawnpoint.global_position + Vector2(randf_range(-10, 10), randf_range(-10, 10))
	scene.marked_position = _marker.global_position
	_ally_keeper.add_child(scene)
	Gameplay.resource -= unit_data.cost
	queue_changed.emit()

func apply_effect(effect: Dictionary) -> void:
	match effect.get("action", ""):
		"unlock_unit":
			var unit: String = effect.get("value", "")
			if unit and unit not in unlocked_units:
				unlocked_units.append(unit)
				queue_changed.emit()
		"enable_autotrain":
			autotrain_available = true
