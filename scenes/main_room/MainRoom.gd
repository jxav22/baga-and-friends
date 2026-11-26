extends Control
## Cosy main room: care loop, navigation, room cosmetics, tutorial overlay.

@onready var bg: TextureRect = $Background
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
@onready var tutorial_layer: Control = $TutorialLayer
@onready var tutorial_text: RichTextLabel = $TutorialLayer/Panel/TutorialText
@onready var tutorial_bird: TextureRect = $TutorialLayer/Chuggadi
@onready var btn_next: Button = $TutorialLayer/Panel/NextButton
@onready var btn_skip: Button = $TutorialLayer/Panel/SkipButton

var _baga: Control
var _tutorial_step: int = 0
var _tutorial_lines: Array[String] = [
	"[b]Chuggadi:[/b] Hello! This is [b]Baga[/b] — tiny, soft, and permanently devastated. That face is the brand, not a cry for help.",
	"[b]Chuggadi:[/b] Baga says \"baga\". You can [b]Pet[/b] and [b]Feed[/b] anytime. Needs are forgiving; nobody dies here.",
	"[b]Chuggadi:[/b] Try [b]Pet[/b] now — soft pats only.",
	"[b]Chuggadi:[/b] Nice. [b]Feed[/b] is always free. Cashew energy.",
	"[b]Chuggadi:[/b] Earn coins in three cosy games: [b]Cashew Catch[/b], [b]Tea Time[/b], and [b]Memory Garden[/b].",
	"[b]Chuggadi:[/b] Spend coins at [b]Chungus Shop[/b]. Cosmetics are cosmetic only — Baga stays devastated either way.",
	"[b]Chuggadi:[/b] You're free. I'll be nearby if you want tips. Soft adventures await.",
]


func _ready() -> void:
	_spawn_baga()
	_connect_signals()
	_refresh_hud()
	_apply_room_cosmetics()
	if not GameState.tutorial_done:
		_start_tutorial()
	else:
		tutorial_layer.visible = false


func _spawn_baga() -> void:
	var packed := load("res://scenes/baga/Baga.tscn") as PackedScene
	_baga = packed.instantiate()
	baga_slot.add_child(_baga)
	_baga.position = Vector2.ZERO


func _connect_signals() -> void:
	GameState.needs_changed.connect(_refresh_hud)
	GameState.coins_changed.connect(func(_c: int) -> void: _refresh_hud())
	GameState.cosmetics_changed.connect(_apply_room_cosmetics)
	$CareBar/FeedButton.pressed.connect(_on_feed)
	$CareBar/PetButton.pressed.connect(_on_pet)
	$CareBar/RestButton.pressed.connect(_on_rest)
	$NavBar/ShopButton.pressed.connect(func() -> void: SceneRouter.go_shop())
	$NavBar/DressButton.pressed.connect(func() -> void: SceneRouter.go_dress_up())
	$NavBar/CashewButton.pressed.connect(func() -> void: SceneRouter.go_cashew_catch())
	$NavBar/TeaButton.pressed.connect(func() -> void: SceneRouter.go_tea_time())
	$NavBar/MemoryButton.pressed.connect(func() -> void: SceneRouter.go_memory_garden())
	$HUD/MuteButton.pressed.connect(_on_mute)
	$HUD/TipsButton.pressed.connect(_replay_tutorial)
	btn_next.pressed.connect(_tutorial_next)
	btn_skip.pressed.connect(_finish_tutorial)


func _refresh_hud() -> void:
	hunger_bar.value = GameState.hunger
	energy_bar.value = GameState.energy
	happiness_bar.value = GameState.happiness
	coins_label.text = "Coins: %d" % GameState.coins
	status_label.text = "Baga is devastated (as usual). Softly."
	$HUD/MuteButton.text = "Unmute" if GameState.muted else "Mute"


func _apply_room_cosmetics() -> void:
	_set_room(room_rug, GameState.get_equipped("room_rug"))
	_set_room(room_plant, GameState.get_equipped("room_plant"))
	_set_room(room_cushion, GameState.get_equipped("room_cushion"))
	_set_room(room_picture, GameState.get_equipped("room_picture"))


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
	SaveManager.autosave()
	if _tutorial_step == 3:
		_tutorial_next()


func _on_pet() -> void:
	GameState.pet()
	AudioManager.play_sfx("pet")
	if _baga and _baga.has_method("play_pet_anim"):
		_baga.play_pet_anim()
	SaveManager.autosave()
	if _tutorial_step == 2:
		_tutorial_next()


func _on_rest() -> void:
	GameState.rest()
	AudioManager.play_sfx("click")
	SaveManager.autosave()


func _on_mute() -> void:
	AudioManager.toggle_mute()
	_refresh_hud()


func _start_tutorial() -> void:
	tutorial_layer.visible = true
	_tutorial_step = 0
	_show_tutorial_line()


func _replay_tutorial() -> void:
	GameState.tutorial_done = false
	_start_tutorial()


func _show_tutorial_line() -> void:
	if _tutorial_step < 0 or _tutorial_step >= _tutorial_lines.size():
		_finish_tutorial()
		return
	tutorial_text.text = _tutorial_lines[_tutorial_step]
	btn_next.text = "Done" if _tutorial_step == _tutorial_lines.size() - 1 else "Next"


func _tutorial_next() -> void:
	AudioManager.play_sfx("click")
	_tutorial_step += 1
	if _tutorial_step >= _tutorial_lines.size():
		_finish_tutorial()
	else:
		_show_tutorial_line()


func _finish_tutorial() -> void:
	tutorial_layer.visible = false
	GameState.complete_tutorial()
	SaveManager.autosave()
	GameState.say("baga...")
