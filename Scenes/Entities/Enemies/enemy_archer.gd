extends CharacterBody2D

var health = 20
var speed = 240
var curr_target:Node2D
var reward_gotten:bool = false
var can_fire:bool = true
var targets:Array = []
@onready var prog_bar = $ProgressBar

@onready var atk_collision = $Attack/CollisionShape2D
var enemy_arrow_scene:PackedScene = preload("res://Scenes/Projectiles/enemy_arrow.tscn")

func _ready() -> void:
	prog_bar.max_value = health
	prog_bar.value = health

func _process(delta: float) -> void:
	if !is_instance_valid(curr_target):
		curr_target = get_closest_target()
		velocity = Vector2.ZERO
	else:
		look_at(curr_target.global_position)
		var direction = (curr_target.global_position - global_position).normalized()
		velocity = speed * direction
	if !is_instance_valid(curr_target):
		curr_target = get_closest_target()
	else:
		look_at(curr_target.global_position)
		if can_fire:
			can_fire = false
			$Attack_rate.start()
			var scene = enemy_arrow_scene.instantiate()
			scene.position = global_position
			scene.rotation = global_rotation
			scene.direction = Vector2.RIGHT.rotated(global_rotation)
			get_tree().root.add_child(scene)
	move_and_slide()

func get_closest_target() -> Node2D:
	var ally_list = get_tree().get_nodes_in_group("Ally")
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
		if !reward_gotten:
			Gameplay.resource += 1
			reward_gotten = true
		queue_free()


func _on_attack_body_entered(body: Node2D) -> void:
	if "damage_func" in body:
		body.damage_func(3)
		can_fire = false
		$Attack_rate.start()


func _on_attack_rate_timeout() -> void:
	can_fire = true

func _on_range_body_entered(body: Node2D) -> void:
	targets.append(body)


func _on_range_body_exited(body: Node2D) -> void:
	targets.erase(body)
