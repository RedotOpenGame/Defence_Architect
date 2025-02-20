extends CharacterBody2D

var health = 20
var speed = 240
var selected:bool = true
var marked_position:Vector2
var can_fire:bool = true
var curr_target:Node2D
var targets:Array = []

var arrow_scene = preload("res://Scenes/Projectiles/ally_arrow.tscn")

@onready var prog_bar = $ProgressBar


func _ready() -> void:
	prog_bar.max_value = health
	prog_bar.value = health

func _process(delta: float) -> void:
	if selected:
		marked_position = get_global_mouse_position()

	if targets != []:
		if !is_instance_valid(curr_target):
			curr_target = get_closest_target()
		look_at(curr_target.global_position)
		if can_fire:
			can_fire = false
			$Firerate.start()
			var scene = arrow_scene.instantiate()
			scene.position = global_position
			scene.rotation = global_rotation
			scene.direction = Vector2.RIGHT.rotated(global_rotation)
			get_tree().root.add_child(scene)
	else:
		if marked_position and marked_position.distance_to(global_position) > 4:
			
			look_at(marked_position)
			var direction = (marked_position - global_position).normalized()
			velocity = speed * direction
		else:
			velocity = Vector2.ZERO
	
	move_and_slide()

func get_closest_target() -> Node2D:
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


func damage_func(amount) -> void:
	health -= amount
	prog_bar.value = health
	if health <= 0:
		queue_free()

func heal_func(amount) -> void:
	health = min(20, health + amount)
	prog_bar.value = health

func _on_firerate_timeout() -> void:
	can_fire = true


func _on_range_body_entered(body: Node2D) -> void:
	targets.append(body)


func _on_range_body_exited(body: Node2D) -> void:
	targets.erase(body)
