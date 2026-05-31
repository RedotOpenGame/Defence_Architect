extends Area2D

var xp_amount:float = 35.0

func _on_body_entered(body: Node2D) -> void:
	if "get_exp" in body:
		body.get_exp(xp_amount)
		queue_free()
