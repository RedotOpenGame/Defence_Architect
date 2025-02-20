extends BaselineAlly

@onready var atk_collision = $Attack/CollisionShape2D
var target_list:Array = []
var curr_target:Node2D

func _process(delta: float) -> void:
	super._process(delta)
	if !is_instance_valid(curr_target):
		curr_target = find_closest_target()
	else:
		marked_position = curr_target.global_position

func _on_attack_body_entered(body: Node2D) -> void:
	if "damage_func" in body:
		body.damage_func(3)
		atk_collision.set_deferred("disabled", true)
		$Attack_rate.start()

func _on_attack_rate_timeout() -> void:
	$Attack/CollisionShape2D.disabled = false


func _on_spotting_range_body_entered(body: Node2D) -> void:
	target_list.append(body)


func _on_spotting_range_body_exited(body: Node2D) -> void:
	target_list.erase(body)

func find_closest_target():
	var enemy_list = target_list
	var closest = INF
	var chosen_enemy
	if enemy_list == []:
		return null
	else:
		for i in enemy_list:
			if global_position.distance_to(i.global_position) < closest:
				closest = global_position.distance_to(i.global_position)
				chosen_enemy = i
		return chosen_enemy
