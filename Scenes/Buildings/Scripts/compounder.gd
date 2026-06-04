extends CharacterBody2D

var health: int = 80
var selected: bool = false
var on_cooldown: bool = false
var units_for_merge:Array = []

const REQUIRED_COUNT: int = 5
const STAT_MULT: float = 5.0

@onready var prog_bar: ProgressBar = $ProgressBar
@onready var cooldown_showcase: ProgressBar = $CooldownShowcase
@onready var cooldown: Timer = $Cooldown

func _ready() -> void:
	prog_bar.max_value = health
	prog_bar.value = health
	cooldown_showcase.max_value = cooldown.wait_time
	

func _process(_delta: float) -> void:
	cooldown_showcase.value = cooldown.wait_time - cooldown.time_left
	if not on_cooldown:
		_check_for_compound()

func _check_for_compound() -> void:
	var by_script: Dictionary = {}
	for node in units_for_merge:
		if not node is BaselineAlly:
			continue
		var s = node.get_script()
		if s == null:
			continue
		if not by_script.has(s):
			by_script[s] = []
		by_script[s].append(node)

	for s in by_script:
		var group: Array = by_script[s]
		if group.size() >= REQUIRED_COUNT:
			_compound(group.slice(0, REQUIRED_COUNT))
			return

func _compound(units: Array) -> void:
	var template: BaselineAlly = units[0]
	var scene_path: String = template.scene_file_path
	if scene_path.is_empty():
		return

	for u in units:
		u.queue_free()

	var packed: PackedScene = load(scene_path)
	if packed == null:
		return

	var x5: BaselineAlly = packed.instantiate()
	x5.max_health *= STAT_MULT
	x5.stat_multiplier = STAT_MULT
	x5.position = position + Vector2(100, 0)

	get_parent().add_child(x5)

	# Add a small label so the x5 unit is visually distinct
	var label := Label.new()
	label.text = "x5"
	label.position = Vector2(-10, -45)
	label.add_theme_color_override("font_color", Color.GOLD)
	x5.add_child(label)

	on_cooldown = true
	$Cooldown.start()

func _on_cooldown_timeout() -> void:
	on_cooldown = false

func damage_func(amount, _pierce: float = 0.0) -> void:
	health -= amount
	prog_bar.value = health
	if health <= 0:
		queue_free()

func check_area_overlaps() -> bool:
	return $PLACEMENT.get_overlapping_areas() == []

func _on_selection_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == 1 and event.pressed:
		selected = not selected


func _on_placement_body_entered(body: Node2D) -> void:
	units_for_merge.append(body)


func _on_placement_body_exited(body: Node2D) -> void:
	units_for_merge.erase(body)
