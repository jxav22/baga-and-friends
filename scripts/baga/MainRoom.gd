extends Control
## Main room care loop: feed / pet / rest + navigation + room cosmetics.

@onready var baga_slot: Control = $BagaSlot
@onready var room_rug: TextureRect = $RoomDecor/Rug
@onready var room_plant: TextureRect = $RoomDecor/Plant
@onready var room_cushion: TextureRect = $RoomDecor/Cushion
@onready var room_picture: TextureRect = $RoomDecor/Picture
@onready var hunger_bar: ProgressBar = $HUD/Needs/HungerBar
@onready var energy_bar: ProgressBar = $HUD/Needs/EnergyBar
@onready var happiness_bar: ProgressBar = $HUD/Needs/HappinessBar
@onready var coins_label: Label = $HUD/CoinsLabel
@onready var status_label: Label = $HUD/StatusLabel
@onready var tutorial_host: Control = $TutorialHost

var _baga: Control


func _ready() -> void:
	_spawn_baga()
	_connect_signals()
	_refresh_hud()
	_apply_room_cosmetics()
	if not GameState.tutorial_done:
		_spawn_tutorial(false)


func _spawn_baga() -> void:
	var packed := load("res://scenes/Baga.tscn") as PackedScene
	_baga = packed.instantiate()
	baga_slot.add_child(_baga)


func _connect_signals() -> void:
	GameState.needs_changed.connect(_refresh_hud)
	GameState.coins_changed.connect(func(_c: int) -> void: _refresh_hud())
	GameState.cosmetics_changed.connect(_apply_room_cosmetics)
	$CareBar/FeedButton.pressed.connect(_on_feed)
	$CareBar/PetButton.pressed.connect(_on_pet)
	$CareBar/RestButton.pressed.connect(_on_rest)
	$NavBar/ShopButton.pressed.connect(func() -> void: SceneRouter.go_shop())
	$NavBar/DressButton.pressed.connect(func() -> void: SceneRouter.go_dress_up())
	$NavBar/CashewButton.pressed.connect(func() -> void: SceneRouter.go_minigame("cashew"))
	$NavBar/TeaButton.pressed.connect(func() -> void: SceneRouter.go_minigame("tea"))
	$NavBar/MemoryButton.pressed.connect(func() -> void: SceneRouter.go_minigame("memory"))
	$HUD/MuteButton.pressed.connect(_on_mute)
	$HUD/TipsButton.pressed.connect(func() -> void: _spawn_tutorial(true))


func _refresh_hud() -> void:
	hunger_bar.value = GameState.hunger
	energy_bar.value = GameState.energy
	happiness_bar.value = GameState.happiness
	coins_label.text = "Coins: %d" % GameState.coins
	var mood := "devastated (as usual)"
	if GameState.happiness > 80.0:
		mood = "devastated, but soft"
	status_label.text = "Baga is %s." % mood
	$HUD/MuteButton.text = "Unmute" if GameState.muted else "Mute"


func _apply_room_cosmetics() -> void:
	var eq := Inventory.get_equipped()
	_set_room(room_rug, str(eq.get("room_rug", "")))
	_set_room(room_plant, str(eq.get("room_plant", "")))
	_set_room(room_cushion, str(eq.get("room_cushion", "")))
	_set_room(room_picture, str(eq.get("room_picture", "")))


func _set_room(node: TextureRect, id: String) -> void:
	if id.is_empty():
		node.visible = false
		node.texture = null
		return
	var item := CosmeticCatalog.get_item(id)
	if item == null:
		node.visible = false
		return
	node.texture = load(item.texture_path) as Texture2D
	node.visible = true


func _on_feed() -> void:
	GameState.feed()
	AudioManager.play_sfx("feed")
	if _baga and _baga.has_method("play_feed_anim"):
		_baga.play_feed_anim()
	SaveManager.autosave()
	_notify_tutorial("feed")


func _on_pet() -> void:
	GameState.pet()
	AudioManager.play_sfx("pet")
	if _baga and _baga.has_method("play_pet_anim"):
		_baga.play_pet_anim()
	SaveManager.autosave()
	_notify_tutorial("pet")


func _on_rest() -> void:
	GameState.rest()
	AudioManager.play_sfx("click")
	if _baga and _baga.has_method("play_rest_anim"):
		_baga.play_rest_anim()
	SaveManager.autosave()


func _on_mute() -> void:
	AudioManager.toggle_mute()
	_refresh_hud()


func _spawn_tutorial(replay: bool) -> void:
	for child in tutorial_host.get_children():
		child.queue_free()
	if not ResourceLoader.exists("res://scenes/Chuggadi.tscn"):
		return
	var packed := load("res://scenes/Chuggadi.tscn") as PackedScene
	var tut := packed.instantiate()
	tutorial_host.add_child(tut)
	if tut.has_method("start_tutorial"):
		tut.call("start_tutorial", replay)


func _notify_tutorial(action: String) -> void:
	for child in tutorial_host.get_children():
		if child.has_method("on_care_action"):
			child.call("on_care_action", action)
