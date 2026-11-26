extends Control
## Equip / unequip owned cosmetics with live Baga preview.

@onready var list: VBoxContainer = $Scroll/List
@onready var baga_slot: Control = $BagaSlot
@onready var info: Label = $Info

var _baga: Control


func _ready() -> void:
	$BackButton.pressed.connect(func() -> void: SceneRouter.go_room())
	$ShopButton.pressed.connect(func() -> void: SceneRouter.go_shop())
	var packed := load("res://scenes/Baga.tscn") as PackedScene
	_baga = packed.instantiate()
	baga_slot.add_child(_baga)
	GameState.cosmetics_changed.connect(_rebuild)
	_rebuild()


func _rebuild() -> void:
	for child in list.get_children():
		child.queue_free()
	var owned := Inventory.owned_ids()
	if owned.is_empty():
		info.text = "No cosmetics yet. Visit Chungus Shop — starting coins buy a cheap bow or cushion."
		return
	info.text = "Tap to equip / unequip. Cosmetics are cosmetic only."
	var eq := Inventory.get_equipped()
	for id in owned:
		var item := CosmeticCatalog.get_item(id)
		if item == null:
			continue
		var equipped_now := str(eq.get(item.slot, "")) == id
		var row := Button.new()
		row.custom_minimum_size = Vector2(0, 40)
		row.text = ("%s %s [%s]" % ["●" if equipped_now else "○", item.name, item.slot])
		var capture := id
		var slot := item.slot
		row.pressed.connect(func() -> void: _toggle(capture, slot))
		list.add_child(row)


func _toggle(id: String, slot: String) -> void:
	var eq := Inventory.get_equipped()
	if str(eq.get(slot, "")) == id:
		Inventory.unequip(slot)
	else:
		Inventory.equip(id)
	_rebuild()
