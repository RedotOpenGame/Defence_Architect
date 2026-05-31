extends Node

func _ready() -> void:
	get_tree().get_first_node_in_group("Player").damage += 1
