extends CharacterBody2D

var health = 50
var wave_reward:int = 1
@onready var prog_bar = $ProgressBar
var selected:bool = false

func _ready() -> void:
	prog_bar.max_value = health
	prog_bar.value = health
	$Label.visible = false
	#$Button.visible = Gameplay.owned_building_upgrades.has("farm1")

func give_money():
	Gameplay.resource += wave_reward

func damage_func(amount, pierce:float = 0.0) -> void:
	health -= amount
	prog_bar.value = health
	if health <= 0:
		queue_free()

func check_area_overlaps() -> bool:

	return $PLACEMENT.get_overlapping_areas() == []


func share_actions() -> Array:
	return ["Upgrade(5 resource)"]

func action_given(id) -> void:
	if id == 0:
		_on_button_pressed()

func _on_control_mouse_entered() -> void:
	$Label.visible = true


func _on_control_mouse_exited() -> void:
	$Label.visible = false


func _on_button_pressed() -> void:
	if Gameplay.resource >= 5:
		Gameplay.resource -= 5
		wave_reward += 1
		$Button.disabled = true
		$Label.text = "New wave =
+2 resource"


func _on_control_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed:
			selected = !selected
			if selected:
				get_tree().get_first_node_in_group("UI").selection(self)
