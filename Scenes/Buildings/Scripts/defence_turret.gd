extends CharacterBody2D

var bullet_scene = preload("res://Scenes/Projectiles/ally_arrow.tscn")

var health: int = 75
@onready var prog_bar = $ProgressBar
@onready var turret = $barrel
@onready var upgrader: UpgradeComponent = $UpgradeComponent

var can_fire: bool = true
var curr_target: Node2D
var targets: Array = []
var selected: bool = false

func _ready() -> void:
	prog_bar.max_value = health
	prog_bar.value = health

func _process(_delta: float) -> void:
	if not is_instance_valid(curr_target):
		curr_target = find_closest_target()
	else:
		turret.look_at(curr_target.global_position)
		if can_fire:
			can_fire = false
			$Firerate.start()
			var scene = bullet_scene.instantiate()
			scene.position = global_position
			scene.rotation = turret.global_rotation
			scene.direction = Vector2.RIGHT.rotated(turret.global_rotation)
			get_tree().root.add_child(scene)

func find_closest_target() -> Node2D:
	if targets.is_empty():
		return null
	var closest := INF
	var chosen_enemy: Node2D
	for i in targets:
		var d = global_position.distance_to(i.global_position)
		if d < closest and i.health > 0:
			closest = d
			chosen_enemy = i
	return chosen_enemy

func damage_func(amount, _pierce: float = 0.0) -> void:
	health -= amount
	prog_bar.value = health
	if health <= 0:
		queue_free()

func check_area_overlaps() -> bool:
	return $PLACEMENT.get_overlapping_areas() == []

func ui_cleanup() -> void:
	pass

func _on_selection_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == 1 and event.pressed:
		selected = not selected
		var ui = get_tree().get_first_node_in_group("UI")
		if selected:
			ui.on_building_selected(self)
		else:
			ui.on_building_deselected()

func _on_selection_mouse_entered() -> void:
	pass

func _on_selection_mouse_exited() -> void:
	pass

func _on_firerate_timeout() -> void:
	can_fire = true

func _on_range_body_exited(body: Node2D) -> void:
	targets.erase(body)

func _on_range_body_entered(body: Node2D) -> void:
	targets.append(body)
