extends Area2D


var speed:float = 750
var direction:Vector2
var damage:float = 2.0
var armor_pierce:float = 0.0

func _process(delta: float) -> void:
	position += speed * direction * delta

func _on_body_entered(body: Node2D) -> void:
	if "damage_func" in body:
		body.damage_func(damage, armor_pierce)
	queue_free()


func _on_cleanup_timeout() -> void:
	queue_free()
