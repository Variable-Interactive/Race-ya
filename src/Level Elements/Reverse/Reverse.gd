extends Timer


var player :KinematicBody2D
var ai :KinematicBody2D

var data = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	yield(get_tree().create_timer(1.0), "timeout")
	player = get_tree().current_scene.find_node("Player")
	ai = get_tree().current_scene.find_node("AI")
	get_data()


func _on_ReverseTimer_timeout() -> void:
	get_data()


func get_data():
	var entry = [player.get_current_state(), ai.get_current_state()]
	data.append(entry)


func rewind():
	var entry = null
	if data.size() > 0:
		if data.size() > 1:
			entry = data.pop_back()
		else:
			entry = data[0]
		if entry:
			player.update_data(entry[0])
			ai.update_data(entry[1])

