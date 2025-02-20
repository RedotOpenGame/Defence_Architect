extends Camera2D

##NOTE:This script is taken from another project, which is why everything is commented.

var area_selection_scene = preload("res://Scenes/Misc/choosing_area.tscn") #meant to select multiple units at once.
var dragging:bool = false
var base_untill_camera_movement = 0.1 #basically for how long player needs to press left click before the camera moves
var untill_camera_movement = 0.1
#var cheat_menu = preload("res://Pew/Scenes/Misc/cheat_menu.tscn")

#@onready var quota = $UI/main/Quota
#@onready var filled_quota = $UI/main/FilledQuota
#@onready var label = $UI/main/WorkerStats
var pressed_mouse_position:Vector2 #The position the camera will move from.
@export var minimal_camera_zoom:float = 0.1 ##How much player can zoom out?
@export var max_camera_zoom:float = 1 ##How much player can zoom in?
@export var zoom_speed:float = 0.05 ##By scrolling once, how much player will change the zoom?
var curr_zoom:float = 0.6

var cheats_activated:bool #the name of the variable speaks for itself.

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

##I guess it kinda works for now. But it's supposed to be more of an "Press and drag"
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
#	quota.text = str("Quota: ", Globals.curr_quota, " / ", Globals.quota)
#	filled_quota.text = str("Times quota was filled: ", Globals.quotas_completed)
	if Input.is_action_pressed("left_mouse_click"): #move the camera
		untill_camera_movement -= delta
		if untill_camera_movement <= 0:
			pressed_mouse_position = get_local_mouse_position()
			position += pressed_mouse_position * delta
	else:
		untill_camera_movement = base_untill_camera_movement
#	if Input.is_action_just_pressed("`"):
#		cheats_activated = true
#		if !get_node_or_null("CheatMenu"):
#			var menu = cheat_menu.instantiate()
#			add_child(menu)
	if Input.is_action_pressed("right_mouse_click") and !dragging:
		dragging = true
		var scene = area_selection_scene.instantiate()
		scene.position = get_local_mouse_position()
		scene.starting_point = get_global_mouse_position()
		add_child(scene)
	if Input.is_action_just_released("right_mouse_click"):
		dragging = false
	if Input.is_action_just_pressed("z") or Input.is_action_just_pressed("middle_mouse_click"):
		for i in get_tree().get_nodes_in_group("Ally"):
			if "is_selected" in i:
				i.is_selected(false)
	if Input.is_action_just_pressed("scroll_down"): #zoom out
		curr_zoom = max(curr_zoom - zoom_speed, minimal_camera_zoom)
		zoom.x = curr_zoom
		zoom.y = curr_zoom
	if Input.is_action_just_pressed("scroll_up"): #zoom in
		curr_zoom = min(curr_zoom + zoom_speed, max_camera_zoom)
		zoom.x = curr_zoom
		zoom.y = curr_zoom
	#if Input.is_action_just_pressed("middle_mouse_click"):
		#_on_disselect_pressed()
	#if Input.is_action_just_pressed("z"):
		#_on_disselect_pressed()

#func _on_disselect_pressed() -> void:
	#for i in get_tree().get_nodes_in_group("Worker"):
		#i.selected = false
		#i.disselect()


#func _on_pause_pressed() -> void:
	#Engine.time_scale = 0
#
#
#func _on_slowed_pressed() -> void:
	#Engine.time_scale = 0.5
#
#
#func _on_normal_pressed() -> void:
	#Engine.time_scale = 1
#
#
#func _on_speeded_pressed() -> void:
	#Engine.time_scale = 1.5
#
#
#func _on_accelerated_pressed() -> void:
	#Engine.time_scale = 2


#func show_worker_stats(worker): #Will tell you everything you need to know about that specific worker (at least supposed to)
	#label.visible = true
	#label.text = "[center][b]Name:%s[/b][/center]
#
#[center]Worker stats:[/center]
#-Health: %s/%s
#-Sanity: %s/%s
#
#[center]Stats[/center]
#-Toughness: %s
#-Psyche: %s
#-Competence: %s
#-Perseverance: %s
#
#[center]Resistances[/center]
#-Pierce: %s
#-Dread: %s
#-Oblivion: %s" % [worker.my_name, worker.curr_health, worker.max_health, worker.curr_sanity, worker.max_sanity, worker.toughness, worker.psyche, worker.competence, worker.persistence, worker.pierce_resistance, worker.dread_resistance, worker.oblivion_resistance]
#
#func hide_worker_stats():
	#label.visible = false
