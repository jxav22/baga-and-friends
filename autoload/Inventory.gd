extends Node
## Contract inventory API over GameState ownership.


func owns(item_id: String) -> bool:
	return GameState.is_owned(item_id)


func purchase(item_id: String) -> bool:
	var item := CosmeticCatalog.get_item(item_id)
	if item == null:
		return false
	if GameState.is_owned(item_id):
		return false
	if not GameState.spend_coins(item.price):
		return false
	GameState.own_cosmetic(item_id)
	SaveManager.autosave()
	AudioManager.play_sfx("buy")
	return true


## Alias
func buy(item_id: String) -> bool:
	return purchase(item_id)


func equip(item_id: String) -> void:
	var item := CosmeticCatalog.get_item(item_id)
	if item == null:
		return
	if not GameState.is_owned(item_id):
		return
	GameState.equip_slot(item.slot, item_id)
	SaveManager.autosave()
	AudioManager.play_sfx("equip")


func unequip(slot: String) -> void:
	GameState.unequip_slot(slot)
	SaveManager.autosave()


func get_equipped() -> Dictionary:
	return GameState.get_equipped_map()


func owned_ids() -> Array[String]:
	return GameState.owned_cosmetics
