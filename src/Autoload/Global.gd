extends Node

# Level options
var level_selected = 1
var levels_cleared = 1


# Actor rferences
var player :CharacterBody2D
var actor :CharacterBody2D

func _enter_tree() -> void:
	load_game()


func _exit_tree() -> void:
	save()


func save():
	var data = {
		"levels_cleared" : levels_cleared,
	}
	var file = FileAccess.open("user://cache.data", FileAccess.WRITE)
	if FileAccess.get_open_error() == OK:
		file.store_line(var_to_str(data))
		file.close()


func load_game():
	var file = FileAccess.open("user://cache.data", FileAccess.READ)
	if FileAccess.get_open_error() == OK:
		var data = str_to_var(file.get_line())
		if data:
			levels_cleared = data.get("levels_cleared", levels_cleared)
