extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Iris/AnimationPlayer.play("fade in")


func _on_TextureButton_pressed() -> void:
# warning-ignore:return_value_discarded
	get_tree().change_scene_to_file("res://src/Levels/MainMenu.tscn")
