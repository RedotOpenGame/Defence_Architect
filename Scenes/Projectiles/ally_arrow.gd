extends Area2D


var speed:float = 400
var direction:Vector2

func _process(delta: float) -> void:
	position += speed * direction * delta

func _on_body_entered(body: Node2D) -> void:
	if "damage_func" in body:
		body.damage_func(1)
	queue_free()


func _on_cleanup_timeout() -> void:
	queue_free()
