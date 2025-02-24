extends Control

func _ready() -> void:
	$Resources.text = str("Eternal Resources: ", Gameplay.eternal_resource)
	
	$BuyFarm.disabled = Gameplay.bought_upgrades.has("unlock_farm_building")
	$FasterBarracks.disabled = Gameplay.bought_upgrades.has("basic_barracks_train_speed")
	$UnlockDefTurrets.disabled = Gameplay.bought_upgrades.has("unlock_defence_turret")
	$UnlockBarrackUpgrade.disabled = Gameplay.bought_upgrades.has("upgrade_barracks_speed1")
	$IncreaseStartResource.disabled = Gameplay.bought_upgrades.has("increase_starting_resource1")
	$UnlockFarmUpgrade.disabled = Gameplay.bought_upgrades.has("unlock_farm_upgrade1")
	
	
	
func _on_buy_farm_pressed() -> void:
	Gameplay.bought_upgrades["unlock_farm_building"] = true
	Gameplay.count_all_bought_upgrades()
	$BuyFarm.disabled = Gameplay.bought_upgrades.has("unlock_farm_building")

func _on_faster_barracks_pressed() -> void:
	Gameplay.bought_upgrades["basic_barracks_train_speed"] = true
	Gameplay.count_all_bought_upgrades()
	$FasterBarracks.disabled = Gameplay.bought_upgrades.has("basic_barracks_train_speed")


func _on_unlock_def_turrets_pressed() -> void:
	Gameplay.bought_upgrades["unlock_defence_turret"] = true
	Gameplay.count_all_bought_upgrades()
	$UnlockDefTurrets.disabled = Gameplay.bought_upgrades.has("unlock_defence_turret")

func _on_unlock_barrack_upgrade_pressed() -> void:
	Gameplay.bought_upgrades["upgrade_barracks_speed1"] = true
	Gameplay.owned_building_upgrades.append("barracks1")
	Gameplay.count_all_bought_upgrades()
	$UnlockBarrackUpgrade.disabled = Gameplay.bought_upgrades.has("upgrade_barracks_speed1")

func _on_increase_start_resource_pressed() -> void:
	Gameplay.bought_upgrades["increase_starting_resource1"] = true
	$IncreaseStartResource.disabled = Gameplay.bought_upgrades.has("increase_starting_resource1")
	Gameplay.count_all_bought_upgrades()


func _on_unlock_farm_upgrade_pressed() -> void:
	Gameplay.bought_upgrades["unlock_farm_upgrade1"] = true
	$UnlockFarmUpgrade.disabled = Gameplay.bought_upgrades.has("unlock_farm_upgrade1")
	Gameplay.count_all_bought_upgrades()

func _on_startnew_pressed() -> void:
	Gameplay.resource = Gameplay.base_resource + Gameplay.starting_resource_bonus
	get_tree().change_scene_to_file("res://Scenes/gameplay.tscn")

func check_if_poor(price:float) -> bool:
	if Gameplay.eternal_resource >= price:
		Gameplay.eternal_resource -= price
		return true
	return false
