extends CharacterBody2D
class_name BaselineAlly

@export var health = 20
@export var speed = 240
var selected:bool = false
var marked_position:Vector2 #Where the player has pointed the cursor, there I'll go.

@onready var prog_bar = $ProgressBar
@onready var control = $Control
@onready var arrow = $Control/TextureRect

func _ready() -> void:
	prog_bar.max_value = health
	prog_bar.value = health
	arrow.visible = selected

func _process(delta: float) -> void:
	arrow.visible = selected
	control.rotation = -rotation
	if selected and Input.is_action_pressed("left_mouse_click"):
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

func is_selected(boolean) -> void:
	selected = boolean

func _on_clickme_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == 1:
			is_selected(true)


func _on_range_body_entered(body: Node2D) -> void:
	pass # Replace with function body.


func _on_range_body_exited(body: Node2D) -> void:
	pass # Replace with function body.
