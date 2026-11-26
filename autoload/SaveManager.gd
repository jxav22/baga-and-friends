extends Node
## Persist GameState to user://save.json

const SAVE_PATH := "user://save.json"


func _ready() -> void:
	# Load after other autoloads exist; deferred so Catalog/Inventory are ready.
	call_deferred("load_game")


func save_game() -> void:
	var data := GameState.to_dict()
	data["version"] = 1
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_warning("SaveManager: could not open save for write")
		return
	file.store_string(JSON.stringify(data, "\t"))
	file.close()


func load_game() -> bool:
	if not FileAccess.file_exists(SAVE_PATH):
		return false
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return false
	var text := file.get_as_text()
	file.close()
	var parsed: Variant = JSON.parse_string(text)
	if typeof(parsed) != TYPE_DICTIONARY:
		push_warning("SaveManager: corrupt save")
		return false
	GameState.from_dict(parsed as Dictionary)
	return true


func clear_save() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)


func autosave() -> void:
	save_game()
