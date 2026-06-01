extends BaselineAlly

@onready var atk_collision = $Attack/CollisionShape2D

func _ready() -> void:
	super._ready()
	engagement_mode = EngagementMode.AGGRESSIVE

func _on_attack_body_entered(body: Node2D) -> void:
	if "damage_func" in body:
		body.damage_func(3)
		atk_collision.set_deferred("disabled", true)
		$Attack_rate.start()

func _on_attack_rate_timeout() -> void:
	$Attack/CollisionShape2D.disabled = false

func _on_spotting_range_body_entered(body: Node2D) -> void:
	_on_range_body_entered(body)

func _on_spotting_range_body_exited(body: Node2D) -> void:
	_on_range_body_exited(body)
