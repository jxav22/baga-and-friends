extends Control
## Cashew Catch — 30s left/right catch falling cashews.

const GAME_TIME := 30.0
const PLAYER_SPEED := 420.0
const SPAWN_EVERY := 0.55

@onready var arena: Control = $Arena
@onready var player: TextureRect = $Arena/Player
@onready var hud: Label = $HUD
@onready var result: Label = $ResultPanel/Result
@onready var instructions: Label = $Instructions
@onready var result_panel: PanelContainer = $ResultPanel

var _playing := false
var _time_left := GAME_TIME
var _score := 0
var _spawn_t := 0.0
var _cashews: Array[TextureRect] = []
var _awarded := false


func _ready() -> void:
	$BackButton.pressed.connect(func() -> void: SceneRouter.go_room())
	$RestartButton.pressed.connect(_restart)
	$StartButton.pressed.connect(_start)
	result_panel.visible = false
	instructions.text = "Move with A/D or ←/→. Catch falling cashews for 30 seconds.\nEach catch = coins. Misses are fine — Baga understands."
	_reset_visuals()


func _reset_visuals() -> void:
	for c in _cashews:
		if is_instance_valid(c):
			c.queue_free()
	_cashews.clear()
	player.position = Vector2(arena.size.x * 0.5 - 24.0, arena.size.y - 64.0)
	hud.text = "Ready"
	_awarded = false


func _start() -> void:
	_restart()


func _restart() -> void:
	_reset_visuals()
	_score = 0
	_time_left = GAME_TIME
	_spawn_t = 0.0
	_playing = true
	result_panel.visible = false
	$StartButton.visible = false
	AudioManager.play_sfx("click")


func _process(delta: float) -> void:
	if not _playing:
		return
	_time_left -= delta
	hud.text = "Time: %d   Cashews: %d" % [ceili(_time_left), _score]
	if _time_left <= 0.0:
		_finish()
		return
	var dir := 0.0
	if Input.is_action_pressed("move_left"):
		dir -= 1.0
	if Input.is_action_pressed("move_right"):
		dir += 1.0
	player.position.x = clampf(
		player.position.x + dir * PLAYER_SPEED * delta,
		0.0,
		maxf(0.0, arena.size.x - player.size.x)
	)
	_spawn_t += delta
	if _spawn_t >= SPAWN_EVERY:
		_spawn_t = 0.0
		_spawn_cashew()
	_update_cashews(delta)


func _spawn_cashew() -> void:
	var c := TextureRect.new()
	c.texture = load("res://assets/shared/cashew.png") as Texture2D
	c.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	c.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	c.size = Vector2(40, 40)
	c.position = Vector2(randf() * maxf(10.0, arena.size.x - 40.0), -40.0)
	arena.add_child(c)
	_cashews.append(c)


func _update_cashews(delta: float) -> void:
	var speed := 180.0 + (GAME_TIME - _time_left) * 4.0
	var keep: Array[TextureRect] = []
	var p_rect := Rect2(player.position, player.size)
	for c in _cashews:
		if not is_instance_valid(c):
			continue
		c.position.y += speed * delta
		var c_rect := Rect2(c.position, c.size)
		if p_rect.intersects(c_rect):
			_score += 1
			AudioManager.play_sfx("coin")
			c.queue_free()
			continue
		if c.position.y > arena.size.y + 20.0:
			c.queue_free()
			continue
		keep.append(c)
	_cashews = keep


func _finish() -> void:
	_playing = false
	var coins := mini(25, 3 + _score)
	if not _awarded:
		GameState.award_coins(coins)
		GameState.play_boost()
		SaveManager.autosave()
		_awarded = true
		AudioManager.play_sfx("buy")
	result_panel.visible = true
	result.text = "Caught %d cashews!\n+%d coins" % [_score, coins]
	$StartButton.visible = true
	$StartButton.text = "Play Again"
