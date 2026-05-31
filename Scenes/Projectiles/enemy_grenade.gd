extends Area2D

var explosion_scene:PackedScene = preload("res://Scenes/Projectiles/enemy_explosion.tscn")

var speed:float = 200
var direction:Vector2
var damage:float = 2.0

func _process(delta: float) -> void:
	position += speed * direction * delta

func _on_until_explosion_timeout() -> void:
	var s = explosion_scene.instantiate()
	s.position = global_position
	s.damage = damage
	call_deferred("add_sibling", s)
	queue_free()


func _on_body_entered(body: Node2D) -> void:
	_on_until_explosion_timeout()
