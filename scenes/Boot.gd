extends Control


func _ready() -> void:
	$Title.text = "Baga & Friends"
	$Subtitle.text = "A soft, slightly devastated virtual pet"
	await get_tree().create_timer(0.9).timeout
	SceneRouter.go_room()
