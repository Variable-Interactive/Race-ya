extends Node

# Level options
var level_selected = 1
var levels_cleared = 1


# Actor rferences
var player :KinematicBody2D
var actor :KinematicBody2D

func _enter_tree() -> void:
	load_game()


func _exit_tree() -> void:
	save()


func save():
	var data = {
		"levels_cleared" : levels_cleared,
	}
	var file := File.new()
	var err = file.open("user://cache.data", File.WRITE)
	if err == OK:
		file.store_var(data)
		file.close()


func load_game():
	var file := File.new()
	var err = file.open("user://cache.data", File.READ)
	if err == OK:
		var data = file.get_var()
		levels_cleared = data.levels_cleared
		file.close()
