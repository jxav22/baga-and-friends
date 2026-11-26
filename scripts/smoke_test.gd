extends Node
## Headless smoke scene. Run:
## godot --headless --path . --scene res://scenes/SmokeTest.tscn


func _ready() -> void:
	await get_tree().process_frame
	print("SMOKE: start coins=", GameState.coins)
	GameState.feed()
	GameState.pet()
	GameState.rest()
	GameState.award_coins(5)
	var cheap := ""
	for item in CosmeticCatalog.all_items():
		if item.price <= GameState.coins:
			cheap = item.id
			break
	if cheap != "":
		var ok := Inventory.purchase(cheap)
		print("SMOKE: purchase ", cheap, " -> ", ok)
		Inventory.equip(cheap)
	SaveManager.autosave()
	var scenes := [
		"res://scenes/MainRoom.tscn",
		"res://scenes/ChungusShop.tscn",
		"res://scenes/DressUp.tscn",
		"res://scenes/CashewCatch.tscn",
		"res://scenes/TeaTime.tscn",
		"res://scenes/MemoryGarden.tscn",
		"res://scenes/Chuggadi.tscn",
		"res://scenes/Baga.tscn",
	]
	for path in scenes:
		var packed := load(path) as PackedScene
		if packed == null:
			push_error("SMOKE FAIL load " + path)
			get_tree().quit(1)
			return
		var node := packed.instantiate()
		add_child(node)
		await get_tree().process_frame
		node.queue_free()
		await get_tree().process_frame
		print("SMOKE OK ", path)
	print("SMOKE PASS coins=", GameState.coins, " owned=", GameState.owned_cosmetics)
	get_tree().quit(0)
