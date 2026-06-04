extends Node2D

@onready var prog_bar: TextureProgressBar = $HyperUI/ProgressBar
@onready var wave_label: Label = $HyperUI/Wave
@onready var ui: CanvasLayer = $UI
@onready var greetings: RichTextLabel = $HyperUI/Tutorial/greetings

@onready var enemy_spawn_pos = $Enemyspawnpos
@onready var enemy_enti = $Entities/Hostiles
@onready var ally_enti = $Entities/Allies

const max_untill_another_attack:float = 30
var waves_working:bool = false #meant to stop waves for debug purposes.
var untill_another_attack:float = max_untill_another_attack
var curr_wave:int = 0
var player_resources = 20
var player_barracks:CharacterBody2D

var enemy_dictionary:Dictionary = {
	#"example":[preload(path/to/scene.tscn), int(spawn_cost), int(spawns at/after wave)]
	"sworder":preload("res://Scenes/Entities/Enemies/enemy_sworder.tscn"),
	"archer":preload("res://Scenes/Entities/Enemies/enemy_archer.tscn"),
	"grenader":preload("res://Scenes/Entities/Enemies/enemy_grenader.tscn"),
	"helicopter":preload("res://Scenes/Entities/Enemies/enemy_helicopter.tscn"),
	"tank":preload("res://Scenes/Entities/Enemies/enemy_armored.tscn")
}

var wave_structure:Dictionary = {
	1:{"sworder":1}, #Just *one* enemy?
	2:{"sworder":3}, #More are coming!
	3:{"sworder":3, "archer":2}, #They've got support!
	4:{"sworder":4, "grenader":2},
	5:{"tank":1},
	6:{"tank":1, "sworder":5},
	7:{"archer":6, "grenader":4},
	8:{"tank":1, "archer":5, "sworder":5},
	9:{"sworder":17},
	10:{"tank":2, "sworder":4, "archer":4, "grenader":4},
}

var tutorial_phase:int = 1
var plr_won:bool = false

func _ready() -> void:
	Gameplay.resource = 6
	prog_bar.max_value = max_untill_another_attack
	prog_bar.value = max_untill_another_attack
	ui.tutorial_mode()
	
func _process(delta: float) -> void:
	
	if tutorial_phase == 1 and is_instance_valid(ui.selected_building):
		tutorial_phase = 2
		$HyperUI/Tutorial/greetings/Crossout.visible = false
		greetings.text = "Great!
Now try placing it down by pressing left click!
You may cancel placement by pressing right click."
	if tutorial_phase == 2 and ally_enti.get_child_count() >= 2:
		player_barracks = ally_enti.get_child(1)
		var value:Array[String] = ["sworder"]
		player_barracks.trainer.unlocked_units = value
		tutorial_phase = 3
		greetings.text = "
Click on barracks you had placed."
		
	if tutorial_phase == 3 and is_instance_valid(ui.selected_trainer):
		tutorial_phase = 4
		Gameplay.resource += 4
		greetings.text = "Barracks can train units.

Make a sworder, would you? Make two, in fact.
		"
	if tutorial_phase == 4 and Gameplay.resource == 0:
		tutorial_phase = 5
		waves_working = true
		greetings.text = "A wave of enemies is approaching.
		
You can make them approach faster by clicking the 'skip' button."
	if tutorial_phase == 5 and curr_wave == 1 and enemy_enti.get_child_count() == 0:
		tutorial_phase = 6
		greetings.text = "...
Just one enemy?
Nevermind, there are more coming.
Get your units close to the townhall in order to heal them!

Not to mention you would need to make more units. As of now, you can train an archer unit(if you don't see it, just unselect and select barracks)."
		var value:Array[String] = ["archer"]
		player_barracks.trainer.unlocked_units = value
		Gameplay.resource += 4
	if tutorial_phase == 6 and curr_wave == 4 and enemy_enti.get_child_count() == 0:
		tutorial_phase = 7
		greetings.text = "Great, continue defeating them!
[phone call] What?
[hangs up phone] Architect, I had been informed that an armored unit is approaching! Sworders are too weak to defeat it, and arrows can't pierce it. Get wizards.
(again, refresh barracks if required)"
		Gameplay.resource += 15
		var value:Array[String] = ["wizard"]
		player_barracks.trainer.unlocked_units = value
	if tutorial_phase == 7 and curr_wave == 5 and enemy_enti.get_child_count() == 0:
		tutorial_phase = 8
		var value:Array[String] = ["sworder", "archer", "wizard"]
		player_barracks.trainer.unlocked_units = value
		
		greetings.text = "You can move camera by pressing right click and dragging.
Change the barracks(if selected) rally point by left click while holding shift.
You may now train any unit you wish.
There's 10 waves in total. Good luck.
" #I think the developer should had left you a note with controls somewhere.
	if tutorial_phase == 8 and plr_won:
		greetings.text = "Seems like I have taught you well.
Now go, and defend the actual sta- I mean, townhall.
Or play around in sandbox, I am not your dad."
 
	
	if waves_working:
		untill_another_attack -= delta
	prog_bar.value = untill_another_attack
	wave_label.text = str("Wave: ", curr_wave)
	if untill_another_attack <= 0 and waves_working:
		curr_wave += 1
		if curr_wave % 3 == 0:
			Gameplay.eternal_resource += 1 * floor(curr_wave / 3)
		untill_another_attack = max_untill_another_attack
		for i in get_tree().get_nodes_in_group("Farm"):
			i.give_money()
		Gameplay.resource += curr_wave
		var wave_budget = ceil(curr_wave ** 1.3)
		# Spawn loop
		if curr_wave in wave_structure:
			# Weighted random pick
			for i in wave_structure[curr_wave]:
				for j in range(wave_structure[curr_wave][i]):
					var s = enemy_dictionary[i].instantiate()
					s.position = enemy_spawn_pos.position + Vector2(randf_range(-300,300), randf_range(-300,300))
					enemy_enti.add_child(s)
		else:
			plr_won = true

			
func _on_skip_pressed() -> void:
	if enemy_enti.get_child_count() <= 50:
		untill_another_attack = 0


func _on_secretrevealer_1_body_entered(body: Node2D) -> void:
	$secrettext1.visible = true


func _on_secretrevealer_1_body_exited(body: Node2D) -> void:
	$secrettext1.visible = false


func _on_show_hide_pressed() -> void:
	greetings.visible = !greetings.visible
