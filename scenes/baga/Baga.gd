extends Control
## Layered Baga character with cosmetic overlays. Always devastated.

@onready var body: TextureRect = $Layers/Body
@onready var skirt: TextureRect = $Layers/Skirt
@onready var shirt: TextureRect = $Layers/Shirt
@onready var shoes: TextureRect = $Layers/Shoes
@onready var head: TextureRect = $Layers/Head
@onready var hair: TextureRect = $Layers/Hair
@onready var face: TextureRect = $Layers/Face
@onready var outfit_overlay: TextureRect = $Layers/OutfitOverlay
@onready var hat_overlay: TextureRect = $Layers/HatOverlay
@onready var accessory_overlay: TextureRect = $Layers/AccessoryOverlay
@onready var feet_overlay: TextureRect = $Layers/FeetOverlay
@onready var speech: Label = $SpeechBubble

var _speech_timer: float = 0.0
var _bob_t: float = 0.0


func _ready() -> void:
	custom_minimum_size = Vector2(256, 320)
	size = Vector2(256, 320)
	if not GameState.cosmetics_changed.is_connected(_on_cosmetics_changed):
		GameState.cosmetics_changed.connect(_on_cosmetics_changed)
	if not GameState.speech_requested.is_connected(_on_speech):
		GameState.speech_requested.connect(_on_speech)
	_apply_cosmetics()
	speech.visible = false


func _process(delta: float) -> void:
	_bob_t += delta
	$Layers.position.y = sin(_bob_t * 2.0) * 3.0
	if _speech_timer > 0.0:
		_speech_timer -= delta
		if _speech_timer <= 0.0:
			speech.visible = false


func _on_cosmetics_changed() -> void:
	_apply_cosmetics()


func _apply_cosmetics() -> void:
	_set_overlay(hat_overlay, GameState.get_equipped("hat"))
	_set_overlay(accessory_overlay, GameState.get_equipped("accessory"))
	_set_overlay(outfit_overlay, GameState.get_equipped("outfit"))
	_set_overlay(feet_overlay, GameState.get_equipped("feet"))
	# Raincoat hides default shirt look a bit
	var has_coat := not GameState.get_equipped("outfit").is_empty()
	shirt.modulate = Color(1, 1, 1, 0.35 if has_coat else 1.0)


func _set_overlay(node: TextureRect, cosmetic_id: String) -> void:
	if cosmetic_id.is_empty():
		node.texture = null
		node.visible = false
		return
	var item := CosmeticCatalog.get_item(cosmetic_id)
	if item == null:
		node.visible = false
		return
	node.texture = load(item.texture_path) as Texture2D
	node.visible = true


func _on_speech(text: String) -> void:
	speech.text = text
	speech.visible = true
	_speech_timer = 2.2


func play_pet_anim() -> void:
	var tw := create_tween()
	tw.tween_property($Layers, "rotation_degrees", -6.0, 0.12)
	tw.tween_property($Layers, "rotation_degrees", 6.0, 0.12)
	tw.tween_property($Layers, "rotation_degrees", 0.0, 0.12)
