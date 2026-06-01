extends CharacterBody2D

var health: int = 50
var wave_reward: int = 1

@onready var prog_bar = $ProgressBar
@onready var upgrader: UpgradeComponent = $UpgradeComponent

var selected: bool = false

func _ready() -> void:
	prog_bar.max_value = health
	prog_bar.value = health
	$Label.visible = false

	upgrader.tiers = [
		{
			"label": "Upgrade Farm",
			"cost": 5,
			"effects": [{"target": "self", "action": "increase_wave_reward", "value": 1}]
		}
	]
	upgrader.tier_purchased.connect(_on_tier_purchased)

func give_money() -> void:
	Gameplay.resource += wave_reward

func damage_func(amount, _pierce: float = 0.0) -> void:
	health -= amount
	prog_bar.value = health
	if health <= 0:
		queue_free()

func check_area_overlaps() -> bool:
	return $PLACEMENT.get_overlapping_areas() == []

func apply_effect(effect: Dictionary) -> void:
	match effect.get("action", ""):
		"increase_wave_reward":
			wave_reward += effect.get("value", 1)
			$Label.text = "New wave =\n+%d resource" % wave_reward

func ui_cleanup() -> void:
	if not selected:
		$Label.visible = false

func _on_tier_purchased(_tier_index: int) -> void:
	var ui = get_tree().get_first_node_in_group("UI")
	if is_instance_valid(ui) and selected:
		ui.refresh_selected_building()

func _on_control_mouse_entered() -> void:
	$Label.visible = true

func _on_control_mouse_exited() -> void:
	if not selected:
		$Label.visible = false

func _on_control_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == 1 and event.pressed:
		selected = not selected
		var ui = get_tree().get_first_node_in_group("UI")
		if selected:
			ui.on_building_selected(self)
		else:
			ui.on_building_deselected()
