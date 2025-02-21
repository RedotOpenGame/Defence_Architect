extends Node

const base_resource:int = 20
var starting_resource_bonus:int = 0
var resource:int = base_resource

var eternal_resource:int = 0
var died_for_the_first_time:bool = false

var owned_buildings:Array = ["barracks"]
var owned_building_upgrades:Array = []
