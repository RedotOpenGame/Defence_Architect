extends BaselineEnemy

@onready var atk_collision: CollisionShape2D = $Attack/CollisionShape2D
@onready var prog_bar = $ProgressBar

var curr_target

func _ready() -> void:
	prog_bar.max_value = health
	prog_bar.value = health

func _process(delta: float) -> void:
	prog_bar.value = health
	curr_target = get_closest_target()
	if !is_instance_valid(curr_target):
		return

	look_at(curr_target.global_position)
	var direction = (curr_target.global_position - global_position).normalized()
	velocity = speed * direction
	move_and_slide()

func _on_attack_body_entered(body: Node2D) -> void:
	if "damage_func" in body:
		body.damage_func(4)
		atk_collision.set_deferred("disabled", true)
		$Attack_rate.start()

func _on_attack_rate_timeout() -> void:
	atk_collision.disabled = false
