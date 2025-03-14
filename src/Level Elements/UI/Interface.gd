extends Control


@onready var anim := $AnimationPlayer

@onready var jump_b: TouchScreenButton = $"%Jump"
@onready var left_b: TouchScreenButton = $"%Left"
@onready var right_b: TouchScreenButton = $"%Right"
@onready var switch_b: TextureButton = $"%Switch"


@onready var player_progress: TextureProgressBar = $"%PlayerProgress"
@onready var player_label: Label = $"%PlayerLabel"
@onready var ai_progress: TextureProgressBar = $"%AIProgress"
@onready var ai_label: Label = $"%AILabel"
var reset_area :Area2D
var rewind_timer :Timer

var left = false
var right = false
var jump = false

func _ready() -> void:
	if OS.get_name() != "Android":
		$GameButtons.visible = false
	anim.play("Fade_in")
	reset_area = get_tree().current_scene.find_child("RestartArea")
	rewind_timer = get_tree().current_scene.find_child("ReverseTimer")
	if reset_area:
		var _err = reset_area.body_entered.connect(reload)

	var player = get_tree().current_scene.find_child("Player")
	var ai = get_tree().current_scene.find_child("AI")
	switch_b.pressed.connect(ai.switch_direction)
	get_tree().paused = false


func _on_Right_pressed() -> void:
	right = true


func _on_Right_released() -> void:
	right = false


func _on_Left_pressed() -> void:
	left = true


func _on_Left_released() -> void:
	left = false


func _on_Jump_pressed() -> void:
	jump = true


func _on_Jump_released() -> void:
	jump = false


func ai_health_changed(value: int):
	# update ai stats
	ai_progress.value = value
	ai_label.text = str(value, "/100")
	if value == 0:
		reload()


func player_health_changed(value: int):
	# update player stats
	player_progress.value = value
	player_label.text = str(value, "/100")
	if value == 0:
		reload()


func reload(_useless_args: Node = null):
	get_tree().paused = true
	$Interfere.visible = false
	anim.play("Fade_out")
	await get_tree().create_timer(1.5).timeout
	var _err = get_tree().reload_current_scene()


func toggle_pause():
	if get_tree().paused:
		get_tree().paused = false
		$Interfere.visible = false
		$Buttons.visible = true
	else:
		get_tree().paused = true
		$Interfere.visible = true
		$Interfere.color = Color("#fff5a49b")
		$Buttons.visible = false


func reverse():
	# for debugging
	if rewind_timer:
		rewind_timer.rewind()
	else: # fall back to reload
		reload()


func _on_ResetButton_pressed() -> void:
	reload()


func _on_PauseButton_pressed() -> void:
	toggle_pause()


func _on_Menu_pressed() -> void:
	get_tree().change_scene_to_file("res://src/Levels/MainMenu.tscn")


func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("pause"):
		toggle_pause()
	if Input.is_action_just_pressed("rewind"):
		if !get_tree().paused:
			reverse()
