extends CharacterBody2D

@onready var recharge: Timer = $recharge
@onready var progress_bar: ProgressBar = $ProgressBar

var unit_supposed_to_be_made:PackedScene = preload("res://Scenes/Entities/Allies/x5_ally_sworder.tscn")

var ready_to_create_unit:bool = true
var units_prepared:Array = []

func _ready() -> void:
	progress_bar.max_value = recharge.wait_time

func _process(delta: float) -> void:
	progress_bar.value = recharge.wait_time - recharge.time_left
	if units_prepared.size() >= 5 and ready_to_create_unit:
		for i in range(0, 5):
			units_prepared[i].queue_free()
		ready_to_create_unit = false
		recharge.start()
		var s = unit_supposed_to_be_made.instantiate()
		s.position = global_position
		get_tree().get_first_node_in_group("Ally_storage").add_child(s)

func _on_recharge_timeout() -> void:
	ready_to_create_unit = true

func check_area_overlaps() -> bool:
	return $PLACEMENT.get_overlapping_areas() == []

func _on_placement_body_entered(body: Node2D) -> void:
	units_prepared.append(body)


func _on_placement_body_exited(body: Node2D) -> void:
	units_prepared.erase(body)
