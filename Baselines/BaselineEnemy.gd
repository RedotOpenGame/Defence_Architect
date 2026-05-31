extends CharacterBody2D

class_name BaselineEnemy

@export var max_health:float = 20.0
@export var defence:float = 0.0
@export var speed:float = 240.0
@export var reward_for_killing:float = 0.0

@onready var health = max_health

var reward_gotten:bool = false # in order to prevent getting rewards twice from the same kill
var targets:Array = []


func find_closest_target() -> Node2D:
	var ally_list = targets
	var closest = INF
	var chosen_enemy
	if ally_list == []:
		return null
	else:
		for i in ally_list:
			if global_position.distance_to(i.global_position) < closest and i.health > 0:
				closest = global_position.distance_to(i.global_position)
				chosen_enemy = i
		return chosen_enemy

func damage_func(amount, pierce:float = 0.0) -> void:
	var functional_defence = max(0, defence - pierce)
	amount = max(0, amount - functional_defence)
	health -= amount
	if health <= 0:
		if !reward_gotten:
			Gameplay.resource += reward_for_killing
			reward_gotten = true
		queue_free()

func get_closest_target() -> Node2D: #works for now, but I think I could change it later
	var ally_list = get_tree().get_nodes_in_group("Ally")
	var closest = INF
	var chosen_enemy
	if ally_list == []:
		return null
	else:
		for i in ally_list:
			if global_position.distance_to(i.global_position) < closest and i.health > 0:
				closest = global_position.distance_to(i.global_position)
				chosen_enemy = i
		return chosen_enemy
