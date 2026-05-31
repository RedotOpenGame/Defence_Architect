extends CharacterBody2D

signal leveled_up

@export var max_health = 20
@onready var health = 20
@export var speed = 240
@export var damage:float = 2

var player_current_level:int = 1
var player_current_xp:float = 0.0
var xp_for_levelup:float = 100



@onready var control: Control = $Control
@onready var experience: ProgressBar = $Control/Experience
@onready var level: Label = $Control/Level

var can_fire:bool = true
var curr_target:Node2D
var targets:Array = []
var arrow_scene = preload("res://Scenes/Projectiles/ally_arrow.tscn")
var marked_position:Vector2 #Where the player has pointed the cursor, there I'll go.

func _ready() -> void:
	level.text = str(player_current_level)

func _process(delta: float) -> void:
	control.rotation = -global_rotation
	if Input.is_action_pressed("left_mouse_click"):
		marked_position = get_global_mouse_position()
	
	
	if marked_position and marked_position.distance_to(global_position) > 4:
		
		look_at(marked_position)
		var direction = (marked_position - global_position).normalized()
		velocity = speed * direction
	else:
		velocity = Vector2.ZERO
	move_and_slide()
	
	if !is_instance_valid(curr_target):
		curr_target = find_closest_target()
	else:
		look_at(curr_target.global_position)
		if can_fire:
			can_fire = false
			$Firerate.start()
			var scene = arrow_scene.instantiate()
			scene.position = global_position
			scene.rotation = global_rotation
			scene.direction = Vector2.RIGHT.rotated(global_rotation)
			scene.damage = damage
			get_tree().root.add_child(scene)

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

func get_exp(amount) -> void:
	player_current_xp += amount
	
	while player_current_xp > xp_for_levelup:
		player_current_level += 1
		leveled_up.emit()
		level.text = str(player_current_level)
		xp_for_levelup += 100 + sqrt(player_current_level)
		experience.max_value = xp_for_levelup
	experience.value = player_current_xp

func _on_firerate_timeout() -> void:
	can_fire = true

func _on_range_body_entered(body: Node2D) -> void:
	targets.append(body)
func _on_range_body_exited(body: Node2D) -> void:
	targets.erase(body)
