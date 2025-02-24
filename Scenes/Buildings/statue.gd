extends CharacterBody2D

@export var health:float = 200

var heal_them:Array = []

@onready var prog_bar = $ProgressBar

func _ready() -> void:
	prog_bar.max_value = health
	prog_bar.value = health

func damage_func(amount) -> void:
	health -= amount
	prog_bar.value = health
	if health <= 0:
		print("The statue is dead.")
		SaveSystem.save_game()
		get_tree().call_deferred("change_scene_to_file", "res://Scenes/menus/post_death_shop.tscn")



func _on_healing_range_body_entered(body: Node2D) -> void:
	if "heal_func" in body:
		heal_them.append(body)


func _on_healing_range_body_exited(body: Node2D) -> void:
	heal_them.erase(body)


func _on_heal_timer_timeout() -> void:
	for i in heal_them:
		i.heal_func(2)
