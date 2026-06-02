extends BaselineAlly

#NOTE: This unit is deprecated.

var can_fire: bool = true
var arrow_scene = preload("res://Scenes/Projectiles/ally_arrow.tscn")

func _ready() -> void:
	super._ready()
	attack_range = 203.0

func _process(delta: float) -> void:
	super._process(delta)
	if not is_instance_valid(chase_target):
		return
	look_at(chase_target.global_position)
	if can_fire and global_position.distance_to(chase_target.global_position) <= attack_range:
		can_fire = false
		$Firerate.start()
		var scene = arrow_scene.instantiate()
		scene.position = global_position
		scene.rotation = global_rotation
		scene.direction = Vector2.RIGHT.rotated(global_rotation)
		get_tree().root.add_child(scene)

func _on_firerate_timeout() -> void:
	can_fire = true
