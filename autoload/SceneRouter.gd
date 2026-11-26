extends Node
## Contract navigation API.

const MAIN_ROOM := "res://scenes/MainRoom.tscn"
const SHOP := "res://scenes/ChungusShop.tscn"
const DRESS_UP := "res://scenes/DressUp.tscn"
const CASHEW_CATCH := "res://scenes/CashewCatch.tscn"
const TEA_TIME := "res://scenes/TeaTime.tscn"
const MEMORY_GARDEN := "res://scenes/MemoryGarden.tscn"
const CHUGGADI := "res://scenes/Chuggadi.tscn"


func go_room() -> void:
	_change(MAIN_ROOM)


## Alias
func go_main_room() -> void:
	go_room()


func go_shop() -> void:
	_change(SHOP)


func go_dress_up() -> void:
	_change(DRESS_UP)


func go_minigame(id: String) -> void:
	match id:
		"cashew":
			_change(CASHEW_CATCH)
		"tea":
			_change(TEA_TIME)
		"memory":
			_change(MEMORY_GARDEN)
		_:
			push_warning("Unknown minigame id: %s" % id)
			go_room()


func go_cashew_catch() -> void:
	go_minigame("cashew")


func go_tea_time() -> void:
	go_minigame("tea")


func go_memory_garden() -> void:
	go_minigame("memory")


func go_chuggadi() -> void:
	_change(CHUGGADI)


func _change(path: String) -> void:
	SaveManager.autosave()
	get_tree().change_scene_to_file(path)
