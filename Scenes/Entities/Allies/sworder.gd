extends CharacterBody2D

var health = 20
var speed = 240
var selected:bool = false
var marked_position:Vector2

@onready var prog_bar = $ProgressBar
@onready var control = $Control
@onready var arrow = $Control/TextureRect

@onready var atk_collision = $Attack/CollisionShape2D

func _ready() -> void:
	prog_bar.max_value = health
	prog_bar.value = health
	arrow.visible = selected
func _process(delta: float) -> void:
	arrow.visible = selected
	control.rotation = -global_rotation
	if selected:
		marked_position = get_global_mouse_position()
	
	
	if marked_position and marked_position.distance_to(global_position) > 4:
		
		look_at(marked_position)
		var direction = (marked_position - global_position).normalized()
		velocity = speed * direction
	else:
		velocity = Vector2.ZERO
	move_and_slide()

func damage_func(amount) -> void:
	health -= amount
	prog_bar.value = health
	if health <= 0:
		queue_free()
	

func heal_func(amount) -> void:
	health = min(20, health + amount)
	prog_bar.value = health

func _on_attack_body_entered(body: Node2D) -> void:
	if "damage_func" in body:
		body.damage_func(3)
		atk_collision.set_deferred("disabled", true)
		$Attack_rate.start()

func _on_attack_rate_timeout() -> void:
	$Attack/CollisionShape2D.disabled = false
