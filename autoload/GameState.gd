extends Node
## Central mutable game state for Baga & Friends.
## Contract API: coins, award_coins, spend_coins, needs, cosmetics, tutorial.

signal coins_changed(new_amount: int)
signal needs_changed
signal cosmetics_changed
signal tutorial_changed
signal speech_requested(text: String)

const MAX_NEED := 100.0
const MIN_NEED := 0.0
const STARTING_COINS := 25
const NEED_DECAY_PER_SEC := 0.35

var coins: int = STARTING_COINS
var hunger: float = 70.0
var energy: float = 70.0
var happiness: float = 75.0
var tutorial_done: bool = false
var muted: bool = false

## Owned cosmetic ids
var owned_cosmetics: Array[String] = []
## slot -> cosmetic id
var equipped: Dictionary = {
	"hat": "",
	"accessory": "",
	"outfit": "",
	"feet": "",
	"room_rug": "",
	"room_plant": "",
	"room_cushion": "",
	"room_picture": "",
}

var _decay_accum: float = 0.0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


func _process(delta: float) -> void:
	_decay_accum += delta
	if _decay_accum < 1.0:
		return
	var steps := int(_decay_accum)
	_decay_accum -= float(steps)
	var changed := false
	for _i in steps:
		if hunger > 15.0:
			hunger = maxf(MIN_NEED, hunger - NEED_DECAY_PER_SEC)
			changed = true
		if energy > 15.0:
			energy = maxf(MIN_NEED, energy - NEED_DECAY_PER_SEC * 0.8)
			changed = true
		if happiness > 20.0:
			happiness = maxf(MIN_NEED, happiness - NEED_DECAY_PER_SEC * 0.5)
			changed = true
	if changed:
		needs_changed.emit()


## Contract: award coins (minigames call this before exit)
func award_coins(amount: int) -> void:
	if amount <= 0:
		return
	coins += amount
	coins_changed.emit(coins)


## Alias kept for older call sites
func add_coins(amount: int) -> void:
	award_coins(amount)


func spend_coins(amount: int) -> bool:
	if amount < 0 or coins < amount:
		return false
	coins -= amount
	coins_changed.emit(coins)
	return true


func feed() -> void:
	hunger = minf(MAX_NEED, hunger + 28.0)
	happiness = minf(MAX_NEED, happiness + 8.0)
	needs_changed.emit()
	say(_pick(["baga...", "mm... baga", "nibble baga"]))


func pet() -> void:
	happiness = minf(MAX_NEED, happiness + 18.0)
	energy = minf(MAX_NEED, energy + 4.0)
	needs_changed.emit()
	say(_pick(["baga...", "*sniff*", "ba...ga"]))


func rest() -> void:
	energy = minf(MAX_NEED, energy + 32.0)
	hunger = maxf(MIN_NEED, hunger - 4.0)
	happiness = minf(MAX_NEED, happiness + 6.0)
	needs_changed.emit()
	say(_pick(["zzz...baga", "soft baga", "..."]))


func play_boost() -> void:
	happiness = minf(MAX_NEED, happiness + 14.0)
	energy = maxf(MIN_NEED, energy - 8.0)
	hunger = maxf(MIN_NEED, hunger - 6.0)
	needs_changed.emit()


func own_cosmetic(id: String) -> void:
	if id.is_empty() or owned_cosmetics.has(id):
		return
	owned_cosmetics.append(id)
	cosmetics_changed.emit()


func is_owned(id: String) -> bool:
	return owned_cosmetics.has(id)


func equip_slot(slot: String, id: String) -> void:
	if not equipped.has(slot):
		return
	if not id.is_empty() and not is_owned(id):
		return
	equipped[slot] = id
	cosmetics_changed.emit()


func unequip_slot(slot: String) -> void:
	if equipped.has(slot):
		equipped[slot] = ""
		cosmetics_changed.emit()


func get_equipped_map() -> Dictionary:
	return equipped.duplicate(true)


func get_equipped(slot: String) -> String:
	return str(equipped.get(slot, ""))


func complete_tutorial() -> void:
	tutorial_done = true
	tutorial_changed.emit()


func say(text: String) -> void:
	speech_requested.emit(text)


func _pick(options: Array) -> String:
	return str(options[randi() % options.size()])


func to_dict() -> Dictionary:
	return {
		"coins": coins,
		"hunger": hunger,
		"energy": energy,
		"happiness": happiness,
		"tutorial_done": tutorial_done,
		"muted": muted,
		"owned_cosmetics": owned_cosmetics.duplicate(),
		"equipped": equipped.duplicate(true),
	}


func from_dict(data: Dictionary) -> void:
	coins = int(data.get("coins", STARTING_COINS))
	hunger = float(data.get("hunger", 70.0))
	energy = float(data.get("energy", 70.0))
	happiness = float(data.get("happiness", 75.0))
	tutorial_done = bool(data.get("tutorial_done", false))
	muted = bool(data.get("muted", false))
	owned_cosmetics.clear()
	var owned: Variant = data.get("owned_cosmetics", [])
	if owned is Array:
		for item in owned:
			owned_cosmetics.append(str(item))
	var eq: Variant = data.get("equipped", {})
	if eq is Dictionary:
		for key in equipped.keys():
			equipped[key] = str(eq.get(key, ""))
	coins_changed.emit(coins)
	needs_changed.emit()
	cosmetics_changed.emit()
	tutorial_changed.emit()
