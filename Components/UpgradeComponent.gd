extends Node
class_name UpgradeComponent

signal tier_purchased(tier_index: int)

## Tier definitions. Set by the building in _ready. Each entry:
##   { "label": String, "cost": int, "effects": Array[Dictionary] }
## Each effect: { "target": "ComponentName"|"self", "action": String, "value": Variant }
var tiers: Array[Dictionary] = []

## If set, the upgrade is only offered when this key is in Gameplay.owned_building_upgrades.
var meta_unlock_key: String = ""

var current_tier: int = -1

func can_upgrade() -> bool:
	return current_tier < tiers.size() - 1

func next_tier_cost() -> int:
	if not can_upgrade():
		return -1
	return tiers[current_tier + 1].get("cost", 0)

func next_tier_label() -> String:
	if not can_upgrade():
		return ""
	return tiers[current_tier + 1].get("label", "Upgrade")

func is_meta_unlocked() -> bool:
	return meta_unlock_key == "" or meta_unlock_key in Gameplay.owned_building_upgrades

func purchase() -> bool:
	if not can_upgrade() or not is_meta_unlocked():
		return false
	var cost = next_tier_cost()
	if Gameplay.resource < cost:
		return false
	Gameplay.resource -= cost
	current_tier += 1
	_apply_tier(current_tier)
	tier_purchased.emit(current_tier)
	return true

func _apply_tier(tier_index: int) -> void:
	var tier = tiers[tier_index]
	var parent = get_parent()
	for effect in tier.get("effects", []) as Array:
		var target_name: String = effect.get("target", "")
		var target: Node
		if target_name == "self":
			target = parent
		else:
			target = parent.get_node_or_null(target_name)
		if target and target.has_method("apply_effect"):
			target.apply_effect(effect)
