extends Control


onready var anim = $ColorRect/AnimationPlayer


func _ready() -> void:
	anim.play("Open")


func _on_Quit_pressed() -> void:
	anim.play("Quit")


func _on_Play_pressed() -> void:
	$Levels.visible = true
# warning-ignore:return_value_discarded
	OS.request_permissions()


func _on_level_selected(level :int) -> void:
	Global.level_selected = level
	anim.play("Play")


func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	$ColorRect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if anim_name == "Quit":
		get_tree().quit()
	if anim_name == "Play":
		var _err = get_tree().change_scene(str("res://src/Levels/Level ", Global.level_selected,".tscn"))


func _on_AnimationPlayer_animation_started(_anim_name: String) -> void:
	$ColorRect.mouse_filter = Control.MOUSE_FILTER_STOP


func _on_CloseLevelMenu_pressed() -> void:
	$Levels.visible = false


func _on_Credits_pressed() -> void:
	$Credits.visible = true


func _on_CloseCredits_pressed() -> void:
	$Credits.visible = false


func _on_Slime_pressed() -> void:
# warning-ignore:return_value_discarded
	OS.shell_open("https://warsvault.itch.io/high-fantasy-slime-enemy")


func _on_Tileset_pressed() -> void:
# warning-ignore:return_value_discarded
	OS.shell_open("https://pzuh.itch.io/free-platformer-tileset")


func _on_Gui_pressed() -> void:
# warning-ignore:return_value_discarded
	OS.shell_open("https://pzuh.itch.io/free-game-gui")


func _on_Music_pressed() -> void:
# warning-ignore:return_value_discarded
	OS.shell_open("https://svl.itch.io/rpg-music-pack-svl")


func _on_Youtube_pressed() -> void:
# warning-ignore:return_value_discarded
	OS.shell_open("https://www.youtube.com/channel/UCkc4E2bJkQ91kejNKKd_U2g")


func _on_Itch_pressed() -> void:
# warning-ignore:return_value_discarded
	OS.shell_open("https://variable-industries.itch.io/")


func _on_Twitter_pressed() -> void:
# warning-ignore:return_value_discarded
	OS.shell_open("https://twitter.com/Variable_ind")
