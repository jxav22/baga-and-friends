extends Node
## Static catalog of shop cosmetics (12 items).

class Cosmetic:
	var id: String
	var name: String
	var description: String
	var slot: String
	var price: int
	var texture_path: String
	var icon_path: String

	func _init(
		p_id: String,
		p_name: String,
		p_desc: String,
		p_slot: String,
		p_price: int,
		p_tex: String,
		p_icon: String
	) -> void:
		id = p_id
		name = p_name
		description = p_desc
		slot = p_slot
		price = p_price
		texture_path = p_tex
		icon_path = p_icon


var items: Array[Cosmetic] = []
var _by_id: Dictionary = {}


func _ready() -> void:
	_build()


func _build() -> void:
	items.clear()
	_by_id.clear()
	_add(Cosmetic.new(
		"hat_beanie", "Soft Beanie", "A sage beanie for rainy moods.",
		"hat", 20, "res://assets/cosmetics/hat_beanie.png", "res://assets/cosmetics/hat_beanie_icon.png"
	))
	_add(Cosmetic.new(
		"hat_chef", "Chef Hat", "For very serious cashew cuisine.",
		"hat", 35, "res://assets/cosmetics/hat_chef.png", "res://assets/cosmetics/hat_chef_icon.png"
	))
	_add(Cosmetic.new(
		"hat_cowboy", "Cowboy Hat", "Yeehaw, but devastated.",
		"hat", 40, "res://assets/cosmetics/hat_cowboy.png", "res://assets/cosmetics/hat_cowboy_icon.png"
	))
	_add(Cosmetic.new(
		"hat_flower_crown", "Flower Crown", "Soft petals, soft feelings.",
		"hat", 30, "res://assets/cosmetics/hat_flower_crown.png", "res://assets/cosmetics/hat_flower_crown_icon.png"
	))
	_add(Cosmetic.new(
		"accessory_bow", "Dusty Bow", "A ribbon that understands.",
		"accessory", 15, "res://assets/cosmetics/accessory_bow.png", "res://assets/cosmetics/accessory_bow_icon.png"
	))
	_add(Cosmetic.new(
		"accessory_spectacles", "Round Spectacles", "For looking wise while crying.",
		"accessory", 25, "res://assets/cosmetics/accessory_spectacles.png", "res://assets/cosmetics/accessory_spectacles_icon.png"
	))
	_add(Cosmetic.new(
		"outfit_raincoat", "Sage Raincoat", "Keeps tears and drizzle similar.",
		"outfit", 45, "res://assets/cosmetics/outfit_raincoat.png", "res://assets/cosmetics/outfit_raincoat_icon.png"
	))
	_add(Cosmetic.new(
		"feet_duck_slippers", "Duck Slippers", "Quack softly, baga loudly.",
		"feet", 22, "res://assets/cosmetics/feet_duck_slippers.png", "res://assets/cosmetics/feet_duck_slippers_icon.png"
	))
	_add(Cosmetic.new(
		"room_rug", "Blush Rug", "A warm oval for tiny feet.",
		"room_rug", 28, "res://assets/cosmetics/room_rug.png", "res://assets/cosmetics/room_rug_icon.png"
	))
	_add(Cosmetic.new(
		"room_plant", "Quiet Plant", "It does not judge. It photosynthesises.",
		"room_plant", 18, "res://assets/cosmetics/room_plant.png", "res://assets/cosmetics/room_plant_icon.png"
	))
	_add(Cosmetic.new(
		"room_cushion", "Gold Cushion", "Sit. Exist. Soft.",
		"room_cushion", 16, "res://assets/cosmetics/room_cushion.png", "res://assets/cosmetics/room_cushion_icon.png"
	))
	_add(Cosmetic.new(
		"room_chungus_pic", "Chungus Portrait", "Shopkeeper merch. Limited feelings.",
		"room_picture", 50, "res://assets/cosmetics/room_chungus_pic.png", "res://assets/cosmetics/room_chungus_pic_icon.png"
	))


func _add(item: Cosmetic) -> void:
	items.append(item)
	_by_id[item.id] = item


func get_item(id: String) -> Cosmetic:
	return _by_id.get(id) as Cosmetic


func all_items() -> Array[Cosmetic]:
	return items


func cheapest_price() -> int:
	var lowest := 9999
	for item in items:
		lowest = mini(lowest, item.price)
	return lowest
