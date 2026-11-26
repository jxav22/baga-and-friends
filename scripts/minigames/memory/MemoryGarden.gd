extends Control
## Stub — filled by parallel worker slice.


func _ready() -> void:
	var btn := get_node_or_null("BackButton")
	if btn:
		btn.pressed.connect(func() -> void: SceneRouter.go_room())
