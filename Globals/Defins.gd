extends Node

const UNIT_DEFINITIONS = {
	"sworder": {
		"scene": preload("res://Scenes/Entities/Allies/ally_sworder.tscn"),
		"cost": 2,
		"train_time": 2.5,
	},
	"archer": {
		"scene": preload("res://Scenes/Entities/Allies/ally_archer_v_2.tscn"),
		"cost": 3,
		"train_time": 2.5,
	},
	"wizard": {
		"scene": preload("res://Scenes/Entities/Allies/ally_wizard.tscn"),
		"cost": 5,
		"train_time":4,
	},
	"flying_turret": {
		"scene": preload("res://Scenes/Entities/Allies/flying_turret.tscn"),
		"cost": 10,
		"train_time": 5.0,
	}
}

const BUILDING_DEFINITIONS = {
	"barracks": {
		"scene":preload("res://Scenes/Buildings/barracks.tscn"), 
		"cost":6
	},
	"farm": {
		"scene":preload("res://Scenes/Buildings/farm.tscn"), 
		"cost":6
	},
	"defence turret": {
		"scene":preload("res://Scenes/Buildings/defence_turret.tscn"), 
		"cost":10
	},
	"factory": {
		"scene":preload("res://Scenes/Buildings/factory.tscn"), 
		"cost":10
	},
	"compounder": {
		"scene":preload("res://Scenes/Buildings/compounder.tscn"),
		"cost":1 #CHANGE LATER
	}
}
