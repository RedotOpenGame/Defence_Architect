extends CharacterBody2D
class_name BaselineAlly

enum EngagementMode { AGGRESSIVE, STANDARD, DEFENSIVE }

@export var max_health: float = 20.0
@export var speed: float = 240.0
@export var defence: float = 0.0
@export var engagement_mode: EngagementMode = EngagementMode.STANDARD
@export var max_chase_distance: float = 250.0
@export var attack_range: float = 0.0

var health: float = 20.0
var selected: bool = false
var marked_position: Vector2 = Vector2.ZERO
var home_position: Vector2 = Vector2.ZERO
var chase_target: Node2D = null
var targets: Array = []

const SEPARATION_RADIUS: float = 42.0
const SEPARATION_FORCE: float = 160.0

@onready var prog_bar = $ProgressBar
@onready var control = get_node_or_null("Control")
@onready var arrow = get_node_or_null("Control/TextureRect")

func _ready() -> void:
	health = max_health
	home_position = global_position
	prog_bar.max_value = max_health
	prog_bar.value = max_health
	if arrow:
		arrow.visible = false

func _process(_delta: float) -> void:
	if arrow:
		arrow.visible = selected
	if control:
		control.rotation = -rotation

	if selected and Input.is_action_pressed("left_mouse_click"):
		marked_position = get_global_mouse_position()
		home_position = marked_position

	_clean_targets()
	find_closest_target()
	_update_movement()
	move_and_slide()

func _clean_targets() -> void:
	targets = targets.filter(func(t): return is_instance_valid(t))
	if not is_instance_valid(chase_target):
		chase_target = null

func find_closest_target() -> Node2D:
	var closest := INF
	var chosen: Node2D = null
	for t in targets:
		var d := global_position.distance_to(t.global_position)
		if d < closest:
			closest = d
			chosen = t
	chase_target = chosen
	return chosen

func _update_movement() -> void:
	var sep := _get_separation()

	match engagement_mode:
		EngagementMode.AGGRESSIVE:
			if is_instance_valid(chase_target):
				_move_toward(chase_target.global_position, sep)
			elif marked_position != Vector2.ZERO and global_position.distance_to(marked_position) > 4.0:
				_move_toward(marked_position, sep)
			else:
				velocity = sep

		EngagementMode.STANDARD:
			# Player-commanded move always takes priority
			if marked_position != Vector2.ZERO and global_position.distance_to(marked_position) > 4.0:
				_move_toward(marked_position, sep)
			elif is_instance_valid(chase_target):
				if global_position.distance_to(home_position) < max_chase_distance:
					_move_toward(chase_target.global_position, sep)
				else:
					_move_toward(home_position, sep)
			else:
				velocity = sep

		EngagementMode.DEFENSIVE:
			if marked_position != Vector2.ZERO and global_position.distance_to(marked_position) > 4.0:
				_move_toward(marked_position, sep)
			else:
				velocity = sep

func _move_toward(target_pos: Vector2, sep: Vector2) -> void:
	look_at(target_pos)
	velocity = (target_pos - global_position).normalized() * speed + sep

func _get_separation() -> Vector2:
	var force := Vector2.ZERO
	var sep_sq := SEPARATION_RADIUS * SEPARATION_RADIUS
	for a in get_tree().get_nodes_in_group("Ally"):
		if a == self or not a is CharacterBody2D:
			continue
		var diff := global_position - a.global_position
		var dist_sq := diff.length_squared()
		if dist_sq < sep_sq and dist_sq > 0.25:
			var dist := sqrt(dist_sq)
			force += diff / dist * (SEPARATION_RADIUS - dist)
	if force.length_squared() > 0.01:
		return force.normalized() * SEPARATION_FORCE
	return Vector2.ZERO

func damage_func(amount, pierce: float = 0.0) -> void:
	var actual := max(0.0, amount - max(0.0, defence - pierce))
	health -= actual
	prog_bar.value = health
	if health <= 0:
		is_selected(false)
		queue_free()

func heal_func(amount) -> void:
	health = min(max_health, health + amount)
	prog_bar.value = health

func is_selected(boolean: bool) -> void:
	selected = boolean
	if boolean:
		get_tree().get_first_node_in_group("UI").selected_units.append(self)
	else:
		get_tree().get_first_node_in_group("UI").selected_units.erase(self)

func _on_clickme_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == 1 and event.pressed:
		if event.double_click:
			_select_all_of_type()
		else:
			is_selected(true)

func _select_all_of_type() -> void:
	var my_script = get_script()
	for a in get_tree().get_nodes_in_group("Ally"):
		if a.get_script() == my_script and a.has_method("is_selected"):
			a.is_selected(true)

func _on_range_body_entered(body: Node2D) -> void:
	if body not in targets:
		targets.append(body)

func _on_range_body_exited(body: Node2D) -> void:
	targets.erase(body)
