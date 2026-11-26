extends Control
## Skippable Chuggadi tutorial overlay (~1 minute).

signal tutorial_finished

@onready var text_label: RichTextLabel = $Panel/Margin/VBox/TutorialText
@onready var bird: TextureRect = $Chuggadi
@onready var btn_next: Button = $Panel/Margin/VBox/Buttons/NextButton
@onready var btn_skip: Button = $Panel/Margin/VBox/Buttons/SkipButton

var _step := 0
var _waiting_action := ""
var _lines: Array[Dictionary] = [
	{"text": "[b]Chuggadi:[/b] Hello! Meet [b]Baga[/b] — tiny crying-kitten energy, cashew shirt, forever devastated. That face is the joke, not neglect.", "wait": ""},
	{"text": "[b]Chuggadi:[/b] Soft care only. Needs are forgiving. Nobody dies. Nobody is punished for being offline.", "wait": ""},
	{"text": "[b]Chuggadi:[/b] Try [b]Pet[/b] — gentle pats. Baga will say baga.", "wait": "pet"},
	{"text": "[b]Chuggadi:[/b] Lovely. Now [b]Feed[/b] — free food always. Cashew solidarity.", "wait": "feed"},
	{"text": "[b]Chuggadi:[/b] Earn coins in [b]Cashew Catch[/b], [b]Tea Time[/b], and [b]Memory Garden[/b]. Cosy games, not grind.", "wait": ""},
	{"text": "[b]Chuggadi:[/b] Spend coins at [b]Chungus Shop[/b]. Cosmetics change outfits, not the devastated soul.", "wait": ""},
	{"text": "[b]Chuggadi:[/b] You're free. Tap Tips anytime to hear me again. Soft adventures!", "wait": ""},
]


func _ready() -> void:
	visible = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	btn_next.pressed.connect(_on_next)
	btn_skip.pressed.connect(_finish)
	# Standalone navigation (not embedded in MainRoom TutorialHost).
	await get_tree().process_frame
	if get_tree().current_scene == self:
		start_tutorial(true)


func start_tutorial(replay: bool = false) -> void:
	visible = true
	mouse_filter = Control.MOUSE_FILTER_STOP
	_step = 0
	_waiting_action = ""
	if replay:
		GameState.tutorial_done = false
	_show()


func on_care_action(action: String) -> void:
	if not visible:
		return
	if _waiting_action != "" and action == _waiting_action:
		_waiting_action = ""
		_on_next()


func _show() -> void:
	if _step < 0 or _step >= _lines.size():
		_finish()
		return
	var entry: Dictionary = _lines[_step]
	text_label.text = str(entry.get("text", ""))
	_waiting_action = str(entry.get("wait", ""))
	btn_next.text = "Done" if _step == _lines.size() - 1 else ("Waiting…" if _waiting_action != "" else "Next")
	btn_next.disabled = _waiting_action != ""
	# Keep the care buttons visible and clickable during the two practice steps.
	var practicing := _waiting_action != ""
	$Panel.offset_top = 340.0 if practicing else 480.0
	$Panel.offset_bottom = 540.0 if practicing else 680.0
	bird.offset_top = 330.0 if practicing else 430.0
	bird.offset_bottom = 490.0 if practicing else 590.0
	# While waiting for Pet/Feed, let care buttons receive clicks through the dimmer.
	var dim := get_node_or_null("Dim") as Control
	if _waiting_action != "":
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		if dim:
			dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	else:
		mouse_filter = Control.MOUSE_FILTER_STOP
		if dim:
			dim.mouse_filter = Control.MOUSE_FILTER_STOP


func _on_next() -> void:
	if _waiting_action != "":
		return
	AudioManager.play_sfx("click")
	_step += 1
	if _step >= _lines.size():
		_finish()
	else:
		_show()


func _finish() -> void:
	visible = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	GameState.complete_tutorial()
	SaveManager.autosave()
	GameState.say("baga...")
	tutorial_finished.emit()
	# If navigated here as a full scene, go home.
	if get_tree().current_scene == self:
		SceneRouter.go_room()
