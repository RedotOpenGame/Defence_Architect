extends CharacterBody2D

var health = 50

@onready var prog_bar = $ProgressBar

func _ready() -> void:
	prog_bar.max_value = health
	prog_bar.value = health


func give_money():
	Gameplay.resource += 2

func damage_func(amount) -> void:
	health -= amount
	prog_bar.value = health
	if health <= 0:
		queue_free()

func check_area_overlaps() -> bool:

	return $PLACEMENT.get_overlapping_areas() == []
