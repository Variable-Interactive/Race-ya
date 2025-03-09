extends TextureButton


signal level_pressed

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var menu = get_tree().current_scene
	var _err = connect("level_pressed", Callable(menu, "_on_level_selected"))
	if get_index() + 1 <= Global.levels_cleared:
		disabled = false
	if !disabled:
		$Label.text = str(get_index() + 1)


func _on_LevelButton_pressed() -> void:
	emit_signal("level_pressed", get_index() + 1)
