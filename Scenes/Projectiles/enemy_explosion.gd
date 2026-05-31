extends Area2D

var damage:float

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "explode":
		queue_free()


func _on_body_entered(body: Node2D) -> void:
	if "damage_func" in body:
		body.damage_func(damage)
