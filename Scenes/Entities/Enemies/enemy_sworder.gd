extends CharacterBody2D

var health = 20
var speed = 240
var curr_target:Node2D
var reward_gotten:bool = false

@onready var prog_bar = $ProgressBar

@onready var atk_collision = $Attack/CollisionShape2D

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
		atk_collision.set_deferred("disabled", true)
		$Attack_rate.start()


func _on_attack_rate_timeout() -> void:
	atk_collision.disabled = false
