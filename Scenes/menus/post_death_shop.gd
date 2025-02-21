extends Control

func _ready() -> void:
	$BuyFarm.disabled = 'farm' in Gameplay.owned_buildings
	$Resources.text = str("Eternal Resources: ", Gameplay.eternal_resource)


func _on_buy_farm_pressed() -> void:
	Gameplay.owned_buildings.append("farm")


func _on_faster_barracks_pressed() -> void:
	pass # Replace with function body.


func _on_unlock_def_turrets_pressed() -> void:
	pass # Replace with function body.


func _on_unlock_barrack_upgrade_pressed() -> void:
	pass # Replace with function body.


func _on_increase_start_resource_pressed() -> void:
	pass # Replace with function body.


func _on_unlock_farm_upgrade_pressed() -> void:
	pass # Replace with function body.


func _on_startnew_pressed() -> void:
	pass # Replace with function body.
