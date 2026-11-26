extends Control


func _ready() -> void:
	var theme_res := load("res://themes/baga_theme.tres")
	if theme_res:
		theme = theme_res
	$Title.text = "Baga & Friends"
	$Subtitle.text = "A soft, slightly devastated virtual pet"
	await get_tree().create_timer(0.9).timeout
	SceneRouter.go_room()
