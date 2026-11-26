extends Control
## Splash → main room.


func _ready() -> void:
	$Title.text = "Baga & Friends"
	$Subtitle.text = "A soft, slightly devastated virtual pet"
	await get_tree().create_timer(1.1).timeout
	SceneRouter.go_main_room()
