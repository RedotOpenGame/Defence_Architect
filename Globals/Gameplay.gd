extends Node

const base_resource:int = 20
var starting_resource_bonus:int = 0
var resource:int = base_resource

var eternal_resource:int = 0
var died_for_the_first_time:bool = false

var owned_buildings:Array = ["barracks"]
var owned_building_upgrades:Array = []

var barracks_train_speed = 1

var bought_upgrades:Dictionary = {} #Will store information about which upgrades were bought.


func count_all_bought_upgrades() -> void:
	barracks_train_speed = 1
	starting_resource_bonus = 0
	owned_buildings = ["barracks"]
	owned_building_upgrades = []
	if bought_upgrades.has("basic_barracks_train_speed"):
		barracks_train_speed *= 1.1
	if bought_upgrades.has("unlock_farm_building"):
		owned_buildings.append("farm")
	if bought_upgrades.has("unlock_defence_turret"):
		owned_buildings.append("defence turret")
	if bought_upgrades.has("upgrade_barracks_speed1"):
		owned_building_upgrades.append("barracks1")
	if bought_upgrades.has("increase_starting_resource1"):
		starting_resource_bonus += 5
	if bought_upgrades.has("unlock_farm_upgrade1"):
		owned_building_upgrades.append("farm1")
