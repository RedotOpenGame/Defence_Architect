extends CharacterBody2D

var bullet_scene = preload("res://Scenes/Projectiles/ally_arrow.tscn")

var health = 75
@onready var prog_bar = $ProgressBar
@onready var turret = $barrel

var can_fire:bool = true
var curr_target:Node2D
var targets:Array = []

func _ready() -> void:
	prog_bar.max_value = health
	prog_bar.value = health

func _process(delta: float) -> void:
	if !is_instance_valid(curr_target):
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
	var ally_list = targets
	var closest = INF
	var chosen_enemy
	if ally_list == []:
		return null
	else:
		for i in ally_list:
			if global_position.distance_to(i.global_position) < closest and i.health > 0:
				closest = global_position.distance_to(i.global_position)
				chosen_enemy = i
		return chosen_enemy


func damage_func(amount) -> void:
	health -= amount
	prog_bar.value = health
	if health <= 0:
		queue_free()

func check_area_overlaps() -> bool:

	return $PLACEMENT.get_overlapping_areas() == []




func _on_firerate_timeout() -> void:
	can_fire = true


func _on_range_body_exited(body: Node2D) -> void:
	targets.erase(body)


func _on_range_body_entered(body: Node2D) -> void:
	targets.append(body)
