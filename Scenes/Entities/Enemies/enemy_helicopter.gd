extends BaselineEnemy

@onready var prog_bar = $ProgressBar

var curr_target:Node2D
var can_fire:bool = true
var enemy_arrow_scene:PackedScene = preload("res://Scenes/Projectiles/enemy_arrow.tscn")

func _ready() -> void:
	prog_bar.max_value = health
	prog_bar.value = health

func _process(delta: float) -> void:
	prog_bar.value = health
	curr_target = get_closest_target()
	if !is_instance_valid(curr_target):
		return
	
	var t_pos = curr_target.global_position
	
	look_at(t_pos)
	if global_position.distance_to(t_pos) < 450:
		if can_fire:
			can_fire = false
			$Attack_rate.start()
			var scene = enemy_arrow_scene.instantiate()
			scene.position = global_position
			scene.rotation = global_rotation
			scene.direction = Vector2.RIGHT.rotated(global_rotation)
			get_tree().root.add_child(scene)
	else:
		#speed = 240
		var direction = (t_pos - global_position).normalized()
		velocity = speed * direction
		move_and_slide()


func _on_range_body_entered(body: Node2D) -> void:
	targets.append(body)


func _on_range_body_exited(body: Node2D) -> void:
	targets.erase(body)


func _on_attack_rate_timeout() -> void:
	can_fire = true
