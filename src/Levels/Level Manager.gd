extends Node2D


onready var player_follower: Camera2D = $"%PlayerFollower"
onready var player: KinematicBody2D = $"%Player"
onready var ai: KinematicBody2D = $"%AI"

export var next_level_name = "Level 1"

onready var interface: ColorRect = $"%Interface"

var entered = 0


func _ready() -> void:
	if OS.get_name() == "Android":
		if next_level_name == "Level 2":
			$Instructions/Panel/Glitch.text = (
"""
Message from Developer...

In case there's a glitch in the game:

You can press the "AI" button (yellow color) to switch your partner's direction manually

Have Fun!!!
""")

func _process(_delta: float) -> void:
	player_follower.position = player.position


func _on_Start_timeout() -> void:
	ai.start = true


func _on_Finisher_body_entered(body: Node) -> void:
	if (body.is_in_group("Player")
		or body.is_in_group("Ai")
	):
		entered += 1
	if entered == 2:
		next_level()


func _on_Finisher_body_exited(body: Node) -> void:
	if (body.is_in_group("Player")
		or body.is_in_group("Ai")
	):
		entered -= 1


func next_level():
	interface.anim.connect("animation_finished", self, "transition_end")
	interface.anim.play("Fade_out")
	Global.levels_cleared += 1
	Global.save()


func transition_end(_anim_name :String):
	interface.anim.disconnect("animation_finished", self, "transition_end")
	var _err = get_tree().change_scene(str("res://src/Levels/", next_level_name,".tscn"))


func _on_Music_finished() -> void:
	$Music.play()

