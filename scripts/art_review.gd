extends Node
## Reproducible in-engine captures. Run ArtReview.tscn with -- --output=export/art-review/after.
## Uses a fixed state and restores the previous save on normal completion.

var _output := "res://export/art-review/after"
var _scene: Control
var _save_bytes := PackedByteArray()
var _had_save := false


func _ready() -> void:
	await get_tree().process_frame
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--output="):
			_output = "res://" + arg.trim_prefix("--output=")
	DirAccess.make_dir_recursive_absolute(_output)
	_had_save = FileAccess.file_exists(SaveManager.SAVE_PATH)
	if _had_save:
		_save_bytes = FileAccess.get_file_as_bytes(SaveManager.SAVE_PATH)
	GameState.set_process(false)
	GameState.from_dict({"coins": 500, "tutorial_done": true, "muted": true})
	AudioManager.set_muted(true)
	for item in CosmeticCatalog.all_items():
		GameState.own_cosmetic(item.id)
	await _show_scene(SceneRouter.MAIN_ROOM)
	await _capture("main-room")
	_scene.call("_spawn_tutorial", true)
	await _capture("tutorial")
	GameState.tutorial_done = true
	await _show_scene(SceneRouter.SHOP)
	await _capture("shop")
	await _show_scene(SceneRouter.DRESS_UP)
	await _capture("dress-up")
	for item in CosmeticCatalog.all_items():
		if item.slot.begins_with("room_"):
			continue
		Inventory.equip(item.id)
		await _capture(item.id)
		Inventory.unequip(item.slot)
	for id in ["hat_flower_crown", "accessory_spectacles", "outfit_raincoat", "feet_duck_slippers"]:
		Inventory.equip(id)
	await _capture("equipped")
	var baga := _scene.get_node("BagaSlot").get_child(0)
	for action in ["pet", "feed", "rest"]:
		baga.call("play_%s_anim" % action)
		await get_tree().create_timer(0.08).timeout
		await _capture("animation-" + action)
		await get_tree().create_timer(0.8).timeout
	for slot in Inventory.get_equipped():
		Inventory.unequip(slot)
	await _capture("unequipped")
	await _show_scene(SceneRouter.MAIN_ROOM)
	for item in CosmeticCatalog.all_items():
		if item.slot.begins_with("room_"):
			Inventory.equip(item.id)
			await _capture(item.id)
			Inventory.unequip(item.slot)
	for item in CosmeticCatalog.all_items():
		if item.slot.begins_with("room_"):
			Inventory.equip(item.id)
	await _capture("decorated-room")
	await _show_scene(SceneRouter.CASHEW_CATCH)
	_scene.call("_start")
	await get_tree().create_timer(1.8).timeout
	await _capture("cashew-catch")
	await _show_scene(SceneRouter.TEA_TIME)
	_scene.call("_start")
	await _capture("tea-time")
	await _show_scene(SceneRouter.MEMORY_GARDEN)
	_scene.call("_start")
	await _capture("memory-garden")
	var grid := _scene.get_node("Grid")
	var cards: Array[Node] = grid.get_children()
	var first := cards[0] as Button
	_scene.call("_on_card", first, str(first.get_meta("face")))
	for card in cards.slice(1):
		if card.get_meta("face") == first.get_meta("face"):
			_scene.call("_on_card", card, str(card.get_meta("face")))
			break
	await get_tree().create_timer(0.6).timeout
	await _capture("memory-matched")
	# Reveal each distinct face for visual review, without changing production card logic.
	for card in cards:
		card.icon = load("res://assets/shared/mem_%s.png" % str(card.get_meta("face")))
		card.text = ""
	await _capture("memory-faces")
	_scene.queue_free()
	await get_tree().process_frame
	if _had_save:
		var file := FileAccess.open(SaveManager.SAVE_PATH, FileAccess.WRITE)
		file.store_buffer(_save_bytes)
		file.close()
	else:
		SaveManager.clear_save()
	print("ART REVIEW PASS: ", _output)
	get_tree().quit()


func _show_scene(path: String) -> void:
	if is_instance_valid(_scene):
		_scene.queue_free()
		await get_tree().process_frame
	_scene = (load(path) as PackedScene).instantiate() as Control
	add_child(_scene)
	await get_tree().process_frame
	await get_tree().process_frame
	seed(1729)


func _capture(label: String) -> void:
	await get_tree().process_frame
	# Explicit draw also works when the review window is hidden or minimized.
	RenderingServer.force_draw()
	var err := get_viewport().get_texture().get_image().save_png(_output.path_join(label + ".png"))
	if err != OK:
		push_error("Capture failed: " + label)
	print("ART CAPTURE: ", label)
