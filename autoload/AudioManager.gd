extends Node
## Simple offline SFX + mute toggle.

var muted: bool = false
var _player: AudioStreamPlayer
var _streams: Dictionary = {}


func _ready() -> void:
	_player = AudioStreamPlayer.new()
	_player.bus = "Master"
	add_child(_player)
	muted = GameState.muted
	_load_optional("pet", "res://assets/sfx/pet.wav")
	_load_optional("feed", "res://assets/sfx/feed.wav")
	_load_optional("buy", "res://assets/sfx/buy.wav")
	_load_optional("equip", "res://assets/sfx/equip.wav")
	_load_optional("coin", "res://assets/sfx/coin.wav")
	_load_optional("click", "res://assets/sfx/click.wav")
	_load_optional("match", "res://assets/sfx/match.wav")
	_load_optional("pour", "res://assets/sfx/pour.wav")
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), muted)


func _load_optional(key: String, path: String) -> void:
	if ResourceLoader.exists(path):
		_streams[key] = load(path)


func set_muted(value: bool) -> void:
	muted = value
	GameState.muted = value
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), value)
	SaveManager.autosave()


func toggle_mute() -> void:
	set_muted(not muted)


func play_sfx(key: String) -> void:
	if muted:
		return
	if not _streams.has(key):
		return
	_player.stream = _streams[key]
	_player.play()
