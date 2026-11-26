extends Control
## Chungus shop — browse, preview, buy 12 cosmetics.

@onready var list: VBoxContainer = $Scroll/List
@onready var preview: TextureRect = $PreviewPanel/Preview
@onready var detail: Label = $PreviewPanel/Detail
@onready var coins_label: Label = $CoinsLabel
@onready var chungus: TextureRect = $Chungus
@onready var speech: Label = $ChungusSpeech

var _selected: String = ""


func _ready() -> void:
	$BackButton.pressed.connect(func() -> void: SceneRouter.go_room())
	$BuyButton.pressed.connect(_on_buy)
	$EquipButton.pressed.connect(_on_equip)
	$DressButton.pressed.connect(func() -> void: SceneRouter.go_dress_up())
	GameState.coins_changed.connect(func(_c: int) -> void: _refresh_coins())
	_refresh_coins()
	_build_list()
	speech.text = "....welcome"
	if CosmeticCatalog.all_items().size() > 0:
		_select(CosmeticCatalog.all_items()[0].id)


func _refresh_coins() -> void:
	coins_label.text = "Coins: %d" % GameState.coins


func _build_list() -> void:
	for child in list.get_children():
		child.queue_free()
	for item in CosmeticCatalog.all_items():
		var row := Button.new()
		row.custom_minimum_size = Vector2(0, 44)
		var owned := "✓ " if Inventory.owns(item.id) else ""
		row.text = "%s%s — %d" % [owned, item.name, item.price]
		var id := item.id
		row.pressed.connect(func() -> void: _select(id))
		list.add_child(row)


func _select(id: String) -> void:
	_selected = id
	var item := CosmeticCatalog.get_item(id)
	if item == null:
		return
	preview.texture = load(item.icon_path) as Texture2D
	var owned := Inventory.owns(id)
	detail.text = "%s\n%s\nPrice: %d%s" % [
		item.name, item.description, item.price,
		" (owned)" if owned else ""
	]
	$BuyButton.disabled = owned or GameState.coins < item.price
	$EquipButton.disabled = not owned
	speech.text = _deadpan(item.name)


func _deadpan(name: String) -> String:
	var lines := [
		"...%s. fine." % name.to_lower(),
		"buy it. or don't.",
		"chungus approves. barely.",
		"...",
	]
	return lines[hash(name) % lines.size()]


func _on_buy() -> void:
	if _selected.is_empty():
		return
	if Inventory.purchase(_selected):
		speech.text = "...sold."
		_build_list()
		_select(_selected)
	else:
		speech.text = "...not enough."


func _on_equip() -> void:
	if _selected.is_empty():
		return
	Inventory.equip(_selected)
	speech.text = "...equipped."
	_build_list()
	_select(_selected)
