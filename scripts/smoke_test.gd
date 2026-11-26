extends Node
## Integration checks; restores the pre-test save on normal completion.

var _failures: Array[String] = []


func _ready() -> void:
	await get_tree().process_frame
	var had_save := FileAccess.file_exists(SaveManager.SAVE_PATH)
	var save_bytes := PackedByteArray()
	if had_save:
		save_bytes = FileAccess.get_file_as_bytes(SaveManager.SAVE_PATH)
	GameState.set_process(false)
	GameState.from_dict({"coins": 500, "tutorial_done": true, "muted": true})
	AudioManager.set_muted(true)
	_check_textures()
	_check_care_and_inventory()
	_check_save_round_trip()
	await _check_scenes()
	await _check_tutorial()
	await _check_cashew()
	await _check_tea()
	await _check_memory()
	if had_save:
		var file := FileAccess.open(SaveManager.SAVE_PATH, FileAccess.WRITE)
		file.store_buffer(save_bytes)
		file.close()
	else:
		SaveManager.clear_save()
	if _failures.is_empty():
		print("SMOKE PASS: assets, care, all cosmetics, version-1 save, tutorial, three minigames")
	else:
		for failure in _failures:
			push_error("SMOKE FAIL: " + failure)
	get_tree().quit(0 if _failures.is_empty() else 1)


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _texture(path: String, size: Vector2) -> void:
	var texture := load(path) as Texture2D
	_expect(texture != null, "load " + path)
	if texture:
		_expect(texture.get_size() == size, "logical size " + path)


func _check_textures() -> void:
	for layer in ["body", "skirt", "shirt", "shoes", "head", "hair", "face", "preview"]:
		_texture("res://assets/baga/%s.png" % layer, Vector2(256, 320))
	_texture("res://assets/room/main_room.png", Vector2(1280, 720))
	_texture("res://assets/chungus/chungus.png", Vector2(280, 240))
	_texture("res://assets/chuggadi/chuggadi.png", Vector2(180, 180))
	_texture("res://assets/shared/cashew.png", Vector2(48, 48))
	_texture("res://assets/shared/teacup.png", Vector2(80, 80))
	_texture("res://assets/shared/card_back.png", Vector2(96, 96))
	for face in ["leaf", "seed", "berry", "cloud", "star", "shell"]:
		_texture("res://assets/shared/mem_%s.png" % face, Vector2(80, 80))
	var decor_sizes := {
		"room_rug": Vector2(320, 120), "room_plant": Vector2(120, 160),
		"room_cushion": Vector2(140, 90), "room_picture": Vector2(100, 120),
	}
	for item in CosmeticCatalog.all_items():
		_texture(item.icon_path, Vector2(96, 96))
		_texture(item.texture_path, decor_sizes.get(item.slot, Vector2(256, 320)))


func _check_care_and_inventory() -> void:
	GameState.hunger = 30.0
	GameState.energy = 30.0
	GameState.happiness = 30.0
	GameState.feed()
	_expect(GameState.hunger == 58.0, "feed restores hunger")
	GameState.pet()
	_expect(GameState.happiness == 56.0, "pet restores happiness")
	GameState.rest()
	_expect(GameState.energy == 66.0, "rest restores energy")
	for item in CosmeticCatalog.all_items():
		var coins_before := GameState.coins
		_expect(Inventory.purchase(item.id), "purchase " + item.id)
		_expect(GameState.coins == coins_before - item.price, "price " + item.id)
		_expect(not Inventory.purchase(item.id), "no duplicate purchase " + item.id)
		Inventory.equip(item.id)
		_expect(GameState.get_equipped(item.slot) == item.id, "equip " + item.id)
		Inventory.unequip(item.slot)
		_expect(GameState.get_equipped(item.slot).is_empty(), "unequip " + item.id)
	for id in ["hat_flower_crown", "accessory_spectacles", "outfit_raincoat", "feet_duck_slippers", "room_rug", "room_plant", "room_cushion", "room_chungus_pic"]:
		Inventory.equip(id)


func _check_save_round_trip() -> void:
	var expected := GameState.to_dict()
	SaveManager.save_game()
	GameState.from_dict({})
	_expect(SaveManager.load_game(), "load existing version-1 save")
	_expect(GameState.to_dict() == expected, "save preserves needs, coins, tutorial, ownership, equipment")


func _check_scenes() -> void:
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
		_expect(packed != null, "scene " + path)
		if packed == null:
			continue
		var node := packed.instantiate()
		add_child(node)
		await get_tree().process_frame
		if path == "res://scenes/Baga.tscn":
			for overlay in ["OutfitOverlay", "FeetOverlay", "AccessoryOverlay", "HatOverlay"]:
				var layer := node.get_node("Layers/" + overlay) as TextureRect
				_expect(layer.visible and layer.texture != null, "combined " + overlay)
			Inventory.unequip("outfit")
			_expect(not node.get_node("Layers/OutfitOverlay").visible, "coat disappears on unequip")
			_expect(node.get_node("Layers/Shirt").modulate.a == 1.0, "shirt opacity restored")
		if path == SceneRouter.MAIN_ROOM:
			for decor in node.get_node("RoomDecor").get_children():
				_expect(decor.visible and decor.texture != null, "room decor " + decor.name)
				_expect(decor.mouse_filter == Control.MOUSE_FILTER_IGNORE, "decor click-through " + decor.name)
		node.queue_free()
		await get_tree().process_frame
		print("SMOKE OK ", path)


func _check_tutorial() -> void:
	GameState.tutorial_done = false
	var room := (load(SceneRouter.MAIN_ROOM) as PackedScene).instantiate()
	add_child(room)
	await get_tree().process_frame
	var tutorial := room.get_node("TutorialHost").get_child(0)
	tutorial.call("_on_next")
	tutorial.call("_on_next")
	_expect(tutorial.get("_waiting_action") == "pet", "tutorial waits for pet")
	_expect(tutorial.mouse_filter == Control.MOUSE_FILTER_IGNORE, "tutorial passes care input")
	room.call("_on_pet")
	_expect(tutorial.get("_waiting_action") == "feed", "pet advances tutorial")
	room.call("_on_feed")
	_expect(tutorial.get("_waiting_action") == "", "feed advances tutorial")
	tutorial.call("_finish")
	_expect(GameState.tutorial_done, "tutorial completion saved")
	await get_tree().create_timer(0.5).timeout
	room.queue_free()
	await get_tree().process_frame


func _check_cashew() -> void:
	var game := (load(SceneRouter.CASHEW_CATCH) as PackedScene).instantiate()
	add_child(game)
	await get_tree().process_frame
	game.set_process(false)
	game.call("_start")
	game.call("_spawn_cashew")
	var cashews: Array = game.get("_cashews")
	var cashew := cashews[0] as TextureRect
	var player := game.get_node("Arena/Player") as TextureRect
	_expect(cashew.size == Vector2(40, 40), "cashew keeps 40x40 bounds")
	cashew.position = player.position
	game.call("_update_cashews", 0.0)
	_expect(game.get("_score") == 1, "cashew collision catches")
	var coins_before := GameState.coins
	game.call("_finish")
	_expect(GameState.coins == coins_before + 4, "cashew reward")
	game.call("_finish")
	_expect(GameState.coins == coins_before + 4, "cashew reward once")
	game.queue_free()
	await get_tree().process_frame


func _check_tea() -> void:
	var game := (load(SceneRouter.TEA_TIME) as PackedScene).instantiate()
	add_child(game)
	await get_tree().process_frame
	game.set_process(false)
	game.call("_start")
	var coins_before := GameState.coins
	for round_index in 5:
		var start := float(game.get("_zone_start"))
		var end := float(game.get("_zone_end"))
		game.get_node("Meter").value = (start + end) * 50.0
		game.call("_pour")
		await get_tree().create_timer(0.65).timeout
	_expect(game.get("_score") == 5, "five successful tea pours")
	_expect(GameState.coins == coins_before + 19, "tea reward")
	game.call("_finish")
	_expect(GameState.coins == coins_before + 19, "tea reward once")
	game.queue_free()
	await get_tree().process_frame


func _check_memory() -> void:
	var game := (load(SceneRouter.MEMORY_GARDEN) as PackedScene).instantiate()
	add_child(game)
	await get_tree().process_frame
	game.call("_start")
	var cards := game.get_node("Grid").get_children()
	var back := load("res://assets/shared/card_back.png") as Texture2D
	for card in cards:
		_expect(card.icon == back and card.text == "", "identical face-down cards")
	var first := cards[0] as Button
	game.call("_on_card", first, str(first.get_meta("face")))
	for card in cards:
		if card.get_meta("face") != first.get_meta("face"):
			game.call("_on_card", card, str(card.get_meta("face")))
			break
	await get_tree().create_timer(0.6).timeout
	for card in cards:
		_expect(card.icon == back, "mismatch restores card back")
	var coins_before := GameState.coins
	for face in ["leaf", "seed", "berry", "cloud", "star", "shell"]:
		for card in cards:
			if card.get_meta("face") == face:
				game.call("_on_card", card, face)
		await get_tree().create_timer(0.6).timeout
	for card in cards:
		_expect(card.disabled and bool(card.get_meta("matched")), "matched card disabled")
		_expect(card.icon != back, "matched face stays visible")
	_expect(GameState.coins == coins_before + 13, "memory reward after seven moves")
	game.call("_finish")
	_expect(GameState.coins == coins_before + 13, "memory reward once")
	game.queue_free()
	await get_tree().process_frame
