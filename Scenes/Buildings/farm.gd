extends CharacterBody2D

var health = 50
var wave_reward:int = 1
@onready var prog_bar = $ProgressBar

func _ready() -> void:
	prog_bar.max_value = health
	prog_bar.value = health
	$Label.visible = false
	

func give_money():
	Gameplay.resource += wave_reward

func damage_func(amount) -> void:
	health -= amount
	prog_bar.value = health
	if health <= 0:
		queue_free()

func check_area_overlaps() -> bool:

	return $PLACEMENT.get_overlapping_areas() == []


func _on_control_mouse_entered() -> void:
	$Label.visible = true


func _on_control_mouse_exited() -> void:
	$Label.visible = false
