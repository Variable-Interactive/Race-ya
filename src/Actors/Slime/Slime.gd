extends KinematicBody2D

export (int) var speed = 500
export (int) var gravity = 2000
export (float, 0, 1.0) var friction = 0.2
export (float, 0, 1.0) var acceleration = 0.3
onready var animation_player: AnimationPlayer = $AnimationPlayer

onready var left: RayCast2D = $Sensors/Left
onready var right: RayCast2D = $Sensors/Right
onready var below_left: RayCast2D = $Sensors/BelowLeft
onready var below_right: RayCast2D = $Sensors/BelowRight
onready var bottom: RayCast2D = $Sensors/Bottom

var velocity = Vector2.ZERO
var general_direction = 1

var destroyed = false


func _ready() -> void:
	$AnimationPlayer.play("Move")


func get_input():
	if !below_left.is_colliding() or !below_right.is_colliding():
		switch_direction()

	# destroy if in water
	if bottom.is_colliding():
		if bottom.get_collider().is_in_group("Water"):
			destroy()

	if left.is_colliding():
		if(
			left.get_collider().is_in_group("Player")
			or left.get_collider().is_in_group("Ai")
		):
			left.get_collider().take_damage(35)
		switch_direction()

	if right.is_colliding():
		if(
			right.get_collider().is_in_group("Player")
			or right.get_collider().is_in_group("Ai")
		):
			right.get_collider().take_damage(35)
		switch_direction()

	var dir = general_direction
	velocity.x = lerp(velocity.x, dir * speed, acceleration)


func _physics_process(delta):
	get_input()
	velocity.y += gravity * delta
	velocity = move_and_slide(velocity, Vector2.UP)


func switch_direction():
	if $Switchtimeout.is_stopped():
		if general_direction == 1:
			general_direction = -1
			$Sensors.scale.x = -1
		elif general_direction == -1:
			general_direction = 1
			$Sensors.scale.x = 1
		$Sprite.flip_h = !$Sprite.flip_h
		$Switchtimeout.start()


func destroy():
	if !destroyed:
		general_direction = 0
		destroyed = true
		left.enabled = false
		right.enabled = false
		animation_player.play("Die")
		yield(get_tree().create_timer(0.6), "timeout")
		queue_free()
