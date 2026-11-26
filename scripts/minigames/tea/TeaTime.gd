extends Control
## Chungus's Tea Time — one-button timing pour rounds.

const ROUNDS := 5

@onready var meter: ProgressBar = $Meter
@onready var sweet_zone: ColorRect = $Meter/SweetZone
@onready var status: Label = $Status
@onready var instructions: Label = $Instructions
@onready var result_panel: PanelContainer = $ResultPanel
@onready var result: Label = $ResultPanel/Result
@onready var cup: TextureRect = $Cup

var _playing := false
var _round := 0
var _score := 0
var _t := 0.0
var _speed := 1.2
var _zone_start := 0.45
var _zone_end := 0.65
var _awarded := false
var _waiting_pour := false


func _ready() -> void:
	$BackButton.pressed.connect(func() -> void: SceneRouter.go_room())
	$RestartButton.pressed.connect(_restart)
	$StartButton.pressed.connect(_start)
	$PourButton.pressed.connect(_pour)
	result_panel.visible = false
	instructions.text = "Press Pour (or Space) when the meter is in the soft gold zone.\n%d gentle pours. Timing, not stress." % ROUNDS
	_reset()


func _reset() -> void:
	_round = 0
	_score = 0
	_awarded = false
	meter.value = 0
	status.text = "Ready for tea"
	$PourButton.disabled = true


func _start() -> void:
	_restart()


func _restart() -> void:
	_reset()
	_playing = true
	_waiting_pour = true
	result_panel.visible = false
	$StartButton.visible = false
	$PourButton.disabled = false
	_next_round()
	AudioManager.play_sfx("click")


func _next_round() -> void:
	_round += 1
	if _round > ROUNDS:
		_finish()
		return
	_t = 0.0
	_speed = 1.0 + _round * 0.15
	_zone_start = randf_range(0.35, 0.55)
	_zone_end = minf(0.92, _zone_start + randf_range(0.14, 0.22))
	_place_zone()
	status.text = "Pour %d / %d — hit the gold" % [_round, ROUNDS]
	_waiting_pour = true


func _place_zone() -> void:
	# Meter is 400px wide visually via anchors; approximate with offsets.
	var width := 400.0
	sweet_zone.offset_left = _zone_start * width
	sweet_zone.offset_right = _zone_end * width


func _process(delta: float) -> void:
	if not _playing or not _waiting_pour:
		return
	_t += delta * _speed
	var wave := absf(sin(_t))
	meter.value = wave * 100.0
	if Input.is_action_just_pressed("action_confirm"):
		_pour()


func _pour() -> void:
	if not _playing or not _waiting_pour:
		return
	_waiting_pour = false
	var v := meter.value / 100.0
	var hit := v >= _zone_start and v <= _zone_end
	AudioManager.play_sfx("pour")
	if hit:
		_score += 1
		status.text = "Perfect pour."
		cup.modulate = Color(1.0, 0.95, 0.7, 1.0)
	else:
		status.text = "A little messy. Still tea."
		cup.modulate = Color(0.85, 0.85, 0.9, 1.0)
	await get_tree().create_timer(0.55).timeout
	cup.modulate = Color.WHITE
	if _playing:
		_next_round()


func _finish() -> void:
	_playing = false
	$PourButton.disabled = true
	var coins := 4 + _score * 3
	if not _awarded:
		GameState.award_coins(coins)
		GameState.play_boost()
		SaveManager.autosave()
		_awarded = true
		AudioManager.play_sfx("buy")
	result_panel.visible = true
	result.text = "Tea done. %d / %d good pours.\n+%d coins" % [_score, ROUNDS, coins]
	$StartButton.visible = true
	$StartButton.text = "Brew Again"
