extends Control
## Chuggadi's Memory Garden — up to 6 pairs, no hard time limit.

const PAIRS := 6
const ICONS := ["leaf", "seed", "berry", "cloud", "star", "shell"]

@onready var grid: GridContainer = $Grid
@onready var status: Label = $Status
@onready var instructions: Label = $Instructions
@onready var result_panel: PanelContainer = $ResultPanel
@onready var result: Label = $ResultPanel/Result

var _deck: Array[String] = []
var _flipped: Array[Button] = []
var _matched := 0
var _lock := false
var _moves := 0
var _playing := false
var _awarded := false
var _card_ids: Dictionary = {}


func _ready() -> void:
	$BackButton.pressed.connect(func() -> void: SceneRouter.go_room())
	$RestartButton.pressed.connect(_restart)
	$StartButton.pressed.connect(_start)
	result_panel.visible = false
	instructions.text = "Flip two cards. Match garden friends. No timer — take a soft breath.\n%d pairs." % PAIRS


func _start() -> void:
	_restart()


func _restart() -> void:
	_matched = 0
	_moves = 0
	_awarded = false
	_playing = true
	_lock = false
	_flipped.clear()
	result_panel.visible = false
	$StartButton.visible = false
	_build_deck()
	status.text = "Matches: 0 / %d" % PAIRS
	AudioManager.play_sfx("click")


func _build_deck() -> void:
	for child in grid.get_children():
		child.queue_free()
	_card_ids.clear()
	_deck = []
	for i in PAIRS:
		_deck.append(ICONS[i])
		_deck.append(ICONS[i])
	_deck.shuffle()
	for idx in _deck.size():
		var icon_name: String = _deck[idx]
		var btn := Button.new()
		btn.custom_minimum_size = Vector2(100, 100)
		btn.text = "?"
		btn.icon = null
		var capture := icon_name
		var bref := btn
		btn.pressed.connect(func() -> void: _on_card(bref, capture))
		grid.add_child(btn)
		_card_ids[btn] = icon_name
		btn.set_meta("face", icon_name)
		btn.set_meta("matched", false)


func _on_card(btn: Button, icon_name: String) -> void:
	if not _playing or _lock:
		return
	if bool(btn.get_meta("matched")):
		return
	if btn in _flipped:
		return
	btn.text = ""
	var tex_path := "res://assets/shared/mem_%s.png" % icon_name
	if ResourceLoader.exists(tex_path):
		btn.icon = load(tex_path) as Texture2D
	else:
		btn.text = icon_name.substr(0, 1).to_upper()
	_flipped.append(btn)
	if _flipped.size() < 2:
		return
	_moves += 1
	_lock = true
	await get_tree().create_timer(0.45).timeout
	var a := _flipped[0]
	var b := _flipped[1]
	if str(a.get_meta("face")) == str(b.get_meta("face")):
		a.set_meta("matched", true)
		b.set_meta("matched", true)
		a.disabled = true
		b.disabled = true
		_matched += 1
		AudioManager.play_sfx("match")
		status.text = "Matches: %d / %d   Moves: %d" % [_matched, PAIRS, _moves]
		if _matched >= PAIRS:
			_finish()
	else:
		a.text = "?"
		b.text = "?"
		a.icon = null
		b.icon = null
		AudioManager.play_sfx("click")
	_flipped.clear()
	_lock = false


func _finish() -> void:
	_playing = false
	var coins := maxi(5, 20 - _moves)
	if not _awarded:
		GameState.award_coins(coins)
		GameState.play_boost()
		SaveManager.autosave()
		_awarded = true
		AudioManager.play_sfx("buy")
	result_panel.visible = true
	result.text = "Garden remembered.\n%d moves · +%d coins" % [_moves, coins]
	$StartButton.visible = true
	$StartButton.text = "Play Again"
