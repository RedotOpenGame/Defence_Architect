extends CanvasLayer

@onready var train_units: GridContainer = $TrainUnits
@onready var resources_label: Label = $Resources
@onready var building_list: ItemList = $BuildingList
@onready var cost_label: Label = $BuildingCost
@onready var trainformation: RichTextLabel = $Trainformation
@onready var actions: VBoxContainer = $Actions

@onready var ally_enti = get_tree().get_first_node_in_group("Ally_storage")

var selected_units:Array = []

var build_mode: bool = false
var building_cost: int
var selected_building  # building being placed (placement mode)
var building_to_spawn

# Currently selected building and its components.
var _selected_building: Node = null
var selected_trainer: TrainerComponent = null
var selected_upgrader: UpgradeComponent = null

func _ready() -> void:
	resources_label.text = str("Resources: ", Gameplay.resource)
	for i in Gameplay.owned_buildings:
		building_list.add_item(i)
	train_units.visible = false
	# Connect action buttons from code so we don't need to edit the tscn.
	actions.get_child(0).pressed.connect(_on_action_pressed.bind(0))
	actions.get_child(1).pressed.connect(_on_action_pressed.bind(1))
	actions.get_child(2).pressed.connect(_on_action_pressed.bind(2))
	actions.get_child(3).pressed.connect(_on_action_pressed.bind(3))

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("1"):
		shortcut_trainer(0)
	if Input.is_action_just_pressed("2"):
		shortcut_trainer(0)
	if Input.is_action_just_pressed("3"):
		shortcut_trainer(0)
	if Input.is_action_just_pressed("4"):
		shortcut_trainer(0)
	if Input.is_action_just_pressed("5"):
		shortcut_trainer(0)
	if Input.is_action_just_pressed("6"):
		shortcut_trainer(0)
	if Input.is_action_just_pressed("f"):
		_on_action_pressed(0)

# ── Building selection ────────────────────────────────────────────────────────

func on_building_selected(building: Node) -> void:
	# Deselect previous building if different.
	if is_instance_valid(_selected_building) and _selected_building != building:
		_selected_building.selected = false
		_selected_building.ui_cleanup()

	_selected_building = building
	selected_trainer = building.get_node_or_null("TrainerComponent")
	selected_upgrader = building.get_node_or_null("UpgradeComponent")

	# Populate train unit slots.
	train_units.visible = selected_trainer != null
	if selected_trainer:
		for i in train_units.get_child_count():
			var slot = train_units.get_child(i)
			if i < selected_trainer.unlocked_units.size():
				slot.get_child(0).text = selected_trainer.unlocked_units[i]
				slot.visible = true
			else:
				slot.get_child(1).text = "0"
				slot.value = 0
				slot.visible = false

	_refresh_actions()

func on_building_deselected() -> void:
	_selected_building = null
	selected_trainer = null
	selected_upgrader = null
	train_units.visible = false
	for btn in actions.get_children():
		btn.visible = false

func refresh_selected_building() -> void:
	if is_instance_valid(_selected_building):
		on_building_selected(_selected_building)

# ── Action buttons ────────────────────────────────────────────────────────────

## Rebuild the Actions panel to reflect the selected building's current state.
func _refresh_actions() -> void:
	for btn in actions.get_children():
		btn.visible = false

	var idx: int = 0

	# Upgrade button — shown when upgrader has a purchasable tier.
	if is_instance_valid(selected_upgrader) and selected_upgrader.can_upgrade() and selected_upgrader.is_meta_unlocked():
		var btn: Button = actions.get_child(idx)
		btn.text = "%s\n%d res" % [selected_upgrader.next_tier_label(), selected_upgrader.next_tier_cost()]
		btn.visible = true
		idx += 1

	# Auto-train toggle — shown once the building has unlocked that capability.
	if is_instance_valid(selected_trainer) and selected_trainer.autotrain_available:
		var btn: Button = actions.get_child(idx)
		btn.text = "Auto-train: %s" % ("ON" if selected_trainer.is_autotraining else "OFF")
		btn.visible = true
		idx += 1

func _on_action_pressed(btn_index: int) -> void:
	# Figure out what each visible button maps to (same order as _refresh_actions).
	var visible_actions: Array[String] = []

	if is_instance_valid(selected_upgrader) and selected_upgrader.can_upgrade() and selected_upgrader.is_meta_unlocked():
		visible_actions.append("upgrade")
	if is_instance_valid(selected_trainer) and selected_trainer.autotrain_available:
		visible_actions.append("autotrain")

	if btn_index >= visible_actions.size():
		return

	match visible_actions[btn_index]:
		"upgrade":
			if selected_upgrader.purchase():
				_refresh_actions()
		"autotrain":
			selected_trainer.toggle_autotrain()
			_refresh_actions()

# ── Per-frame update ──────────────────────────────────────────────────────────

func _process(_delta: float) -> void:
	resources_label.text = str("Resources: ", Gameplay.resource)

	if is_instance_valid(selected_trainer) and train_units.visible:
		for i in train_units.get_child_count():
			var slot = train_units.get_child(i)
			if not slot.visible:
				break
			var unit_id = selected_trainer.unlocked_units[i]
			var queue_count = selected_trainer.unit_wait_list.count(unit_id)
			slot.get_child(1).text = str(queue_count)
			# Show training progress only on the unit at the front of the queue.
			var t = selected_trainer._timer
			if not selected_trainer.unit_wait_list.is_empty() and selected_trainer.unit_wait_list[0] == unit_id:
				slot.max_value = t.wait_time
				slot.value = t.wait_time - t.time_left
			else:
				slot.max_value = 1.0
				slot.value = 0.0

	# Building placement.
	if selected_building:
		selected_building.global_position = lerp(selected_building.global_position, ally_enti.get_global_mouse_position(), 10 * _delta)
		selected_building.collision_layer = 512
		selected_building.collision_mask = 512
		selected_building.modulate = Color(1, 1, 1, 0.4)
		selected_building.process_mode = ProcessMode.PROCESS_MODE_DISABLED
		if selected_building not in ally_enti.get_children():
			ally_enti.add_child(selected_building)

		if Input.is_action_just_pressed("left_mouse_click"):
			if build_mode and Gameplay.resource >= building_cost:
				if selected_building.check_area_overlaps():
					spawn_building()
					Gameplay.resource -= building_cost
			build_mode = true
		if Input.is_action_just_pressed("right_mouse_click"):
			ally_enti.remove_child(selected_building)
			building_to_spawn = null
			selected_building = null
			build_mode = false

# ── Training slot input ───────────────────────────────────────────────────────

func shortcut_trainer(slot_id:int) -> void:
	if not is_instance_valid(selected_trainer):
		return
	if slot_id >= selected_trainer.unlocked_units.size():
		return
	selected_trainer.queue_unit(selected_trainer.unlocked_units[slot_id])

func gui_to_trainer(slot_id: int, event: InputEvent) -> void:
	if not is_instance_valid(selected_trainer):
		return
	if slot_id >= selected_trainer.unlocked_units.size():
		return
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			selected_trainer.queue_unit(selected_trainer.unlocked_units[slot_id])
		elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			selected_trainer.cancel_unit(slot_id)

func show_train_info(slot_id: int) -> void:
	if not is_instance_valid(selected_trainer):
		return
	if slot_id >= selected_trainer.unlocked_units.size():
		return
	var unit_name = selected_trainer.unlocked_units[slot_id]
	trainformation.text = "\nCost: %s\nTrain time: %s" % [
		Defins.UNIT_DEFINITIONS[unit_name]["cost"],
		Defins.UNIT_DEFINITIONS[unit_name]["train_time"]
	]

# ── Building list (placement) ─────────────────────────────────────────────────

func _on_building_list_item_clicked(index: int, _at_position: Vector2, mouse_button_index: int) -> void:
	if mouse_button_index == 1:
		if is_instance_valid(selected_building):
			selected_building.queue_free()
		var build_name = building_list.get_item_text(index)
		var new_building = Defins.BUILDING_DEFINITIONS[build_name]["scene"]
		if Gameplay.resource >= Defins.BUILDING_DEFINITIONS[build_name]["cost"]:
			building_cost = Defins.BUILDING_DEFINITIONS[build_name]["cost"]
			selected_building = new_building.instantiate()
			building_to_spawn = new_building
			build_mode = false

func _on_building_list_item_hovered(index: int) -> void:
	cost_label.text = str("Cost: ", Defins.BUILDING_DEFINITIONS[building_list.get_item_text(index)]["cost"])

func spawn_building() -> void:
	var building = building_to_spawn.instantiate()
	building.global_position = ally_enti.get_global_mouse_position()
	ally_enti.add_child(building)

func _on_building_list_mouse_exited() -> void:
	cost_label.text = "Cost: "

# ── TrainUnits slot signal forwarders ─────────────────────────────────────────

func _on_texture_rect_gui_input(event: InputEvent) -> void:
	gui_to_trainer(0, event)

func _on_texture_rect_2_gui_input(event: InputEvent) -> void:
	gui_to_trainer(1, event)

func _on_texture_rect_3_gui_input(event: InputEvent) -> void:
	gui_to_trainer(2, event)

func _on_texture_rect_4_gui_input(event: InputEvent) -> void:
	gui_to_trainer(3, event)

func _on_texture_rect_5_gui_input(event: InputEvent) -> void:
	gui_to_trainer(4, event)

func _on_texture_rect_6_gui_input(event: InputEvent) -> void:
	gui_to_trainer(5, event)

func _on_texture_rect_mouse_entered() -> void:
	show_train_info(0)

func _on_texture_rect_mouse_exited() -> void:
	trainformation.text = ""

func _on_texture_rect_2_mouse_entered() -> void:
	show_train_info(1)

func _on_texture_rect_2_mouse_exited() -> void:
	trainformation.text = ""

func _on_texture_rect_3_mouse_entered() -> void:
	show_train_info(2)

func _on_texture_rect_3_mouse_exited() -> void:
	trainformation.text = ""

func _on_texture_rect_4_mouse_entered() -> void:
	show_train_info(3)

func _on_texture_rect_4_mouse_exited() -> void:
	trainformation.text = ""

func _on_texture_rect_5_mouse_entered() -> void:
	show_train_info(4)

func _on_texture_rect_5_mouse_exited() -> void:
	trainformation.text = ""

func _on_texture_rect_6_mouse_entered() -> void:
	show_train_info(5)

func _on_texture_rect_6_mouse_exited() -> void:
	trainformation.text = ""

# ── Misc ──────────────────────────────────────────────────────────────────────

func _on_surrender_pressed() -> void:
	SaveSystem.save_game()
	get_tree().change_scene_to_file("res://Scenes/menus/post_death_shop.tscn")

# ── Unit Control ──────────────────────────────────────────────────────────────────────

func _on_aggressive_pressed() -> void:
	for i in selected_units:
		if is_instance_valid(i):
			i.engagement_mode = i.EngagementMode.AGGRESSIVE


func _on_leash_pressed() -> void:
	for i in selected_units:
		if is_instance_valid(i):
			i.engagement_mode = i.EngagementMode.STANDARD


func _on_defend_pressed() -> void:
	for i in selected_units:
		if is_instance_valid(i):
			i.engagement_mode = i.EngagementMode.DEFENSIVE
