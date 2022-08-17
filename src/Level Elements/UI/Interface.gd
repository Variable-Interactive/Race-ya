extends Control


onready var anim := $AnimationPlayer

onready var player_progress: TextureProgress = $"%PlayerProgress"
onready var player_label: Label = $"%PlayerLabel"
onready var ai_progress: TextureProgress = $"%AIProgress"
onready var ai_label: Label = $"%AILabel"
var reset_area :Area2D
var rewind_timer :Timer


func _ready() -> void:
	anim.play("Fade_in")
	reset_area = get_tree().current_scene.find_node("RestartArea")
	rewind_timer = get_tree().current_scene.find_node("ReverseTimer")
	if reset_area:
		var _err = reset_area.connect("body_entered", self, "reverse")


func ai_health_changed(value: int):
	# update ai stats
	ai_progress.value = value
	ai_label.text = str(value, "/100")
	if value == 0:
		reverse()


func player_health_changed(value: int):
	# update player stats
	player_progress.value = value
	player_label.text = str(value, "/100")
	if value == 0:
		reverse()


func reload():
	get_tree().paused = true
	$Interfere.visible = false
	anim.play("Fade_out")
	yield(get_tree().create_timer(1.5), "timeout")
	var _err = get_tree().reload_current_scene()
	get_tree().paused = false


func toggle_pause():
	if get_tree().paused:
		get_tree().paused = false
		$Interfere.visible = false
		$Buttons.visible = true
	else:
		get_tree().paused = true
		$Interfere.visible = true
		$Interfere.color = Color("9bfff5a4")
		$Buttons.visible = false


func reverse():
	if rewind_timer:
		rewind_timer.rewind()
	else: # fall back to reload(
		reload()


func _on_ResetButton_pressed() -> void:
	reload()


func _on_PauseButton_pressed() -> void:
	toggle_pause()


func _on_Menu_pressed() -> void:
	var _err = get_tree().change_scene("res://src/Levels/MainMenu.tscn")
	get_tree().paused = false

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("pause"):
		toggle_pause()
	if Input.is_action_just_pressed("rewind"):
		if !get_tree().paused:
			reverse()
