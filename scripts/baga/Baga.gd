extends Control
## Layered Baga — crying-kitten chibi, always devastated.

@onready var shirt: TextureRect = $Layers/Shirt
@onready var outfit_overlay: TextureRect = $Layers/OutfitOverlay
@onready var hat_overlay: TextureRect = $Layers/HatOverlay
@onready var accessory_overlay: TextureRect = $Layers/AccessoryOverlay
@onready var feet_overlay: TextureRect = $Layers/FeetOverlay
@onready var speech: Label = $SpeechBubble

var _speech_timer: float = 0.0
var _bob_t: float = 0.0


func _ready() -> void:
	custom_minimum_size = Vector2(256, 320)
	if not GameState.cosmetics_changed.is_connected(_apply_cosmetics):
		GameState.cosmetics_changed.connect(_apply_cosmetics)
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


func _apply_cosmetics() -> void:
	var eq := Inventory.get_equipped()
	_set_overlay(hat_overlay, str(eq.get("hat", "")))
	_set_overlay(accessory_overlay, str(eq.get("accessory", "")))
	_set_overlay(outfit_overlay, str(eq.get("outfit", "")))
	_set_overlay(feet_overlay, str(eq.get("feet", "")))
	shirt.modulate = Color(1, 1, 1, 0.35 if not str(eq.get("outfit", "")).is_empty() else 1.0)


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


func play_feed_anim() -> void:
	var tw := create_tween()
	tw.tween_property($Layers, "scale", Vector2(1.05, 0.95), 0.1)
	tw.tween_property($Layers, "scale", Vector2.ONE, 0.12)


func play_rest_anim() -> void:
	var tw := create_tween()
	tw.tween_property($Layers, "modulate", Color(0.9, 0.9, 1.0, 1.0), 0.3)
	tw.tween_property($Layers, "modulate", Color.WHITE, 0.4)
