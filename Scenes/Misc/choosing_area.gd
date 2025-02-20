extends Area2D

@onready var line = $Line2D
@onready var collision = $CollisionShape2D

var starting_point:Vector2 #starting point
var ending_point:Vector2 #where the mouse is dragged to

func _ready() -> void:
	collision.shape["size"] = Vector2.ZERO

func _process(delta: float) -> void:
	if Input.is_action_pressed("right_mouse_click"):
		ending_point = get_global_mouse_position()
		line.points[1].x = ending_point.x - starting_point.x
		line.points[2] = ending_point - starting_point
		line.points[3].y = ending_point.y - starting_point.y
		collision.shape["size"] = abs(ending_point - starting_point)
		collision.position = (ending_point - starting_point) / 2
	if Input.is_action_just_released("right_mouse_click"):
		var bodies_colliding = get_overlapping_bodies()
		for i in bodies_colliding:
			if "is_selected" in i:
				i.is_selected(true)
		queue_free()
