extends Node

const turret_scene = preload("res://Scenes/Buildings/defence_turret.tscn")

func _ready() -> void:
	var scene = turret_scene.instantiate()
	get_tree().get_first_node_in_group("Ally_storage").add_child(scene)
