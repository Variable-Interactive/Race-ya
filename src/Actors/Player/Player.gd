extends CharacterBody2D


var start = true

@export var max_health: int = 100
@export var recovery_time: int = 5 #Health per second
@export var speed: int = 500
@export var jump_speed: int = -700
@export var gravity: int = 2000
@export var friction = 0.2 # (float, 0, 1.0)
@export var acceleration = 0.3 # (float, 0, 1.0)
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var damage_interval: Timer = $DamageInterval

var jump_started = false
var play_on_land = false
@onready var slime_detector: RayCast2D = $"%SlimeDetector"

var jump_count = 0

# Health options
var health = 10
signal health_changed

var interface


func _ready() -> void:
	Global.player = self
	# wait for interface to start
	await get_tree().process_frame
	if !interface:
		interface = get_tree().current_scene.find_child("Interface")
	var _err = health_changed.connect(interface.player_health_changed)
	set_health(max_health)


func get_current_state():
	var data = {
		"position" :position,
		"velocity" : velocity,
		"health" : health,
	}
	return data


func update_data(data):
	position = data.position
	velocity = data.velocity
	health = data.health


func set_health(value):
	if health != value:
		health = value
		emit_signal("health_changed", health)


func take_damage(value):
	if damage_interval.is_stopped():
		set_health(health - value)
		damage_interval.start()
		$HitFlash.play("Hit")


func get_input(_dummy = null):
	play_on_land = (velocity.length() > 700)
	var dir: int = 0
	if !interface:
		interface = get_tree().current_scene.find_child("Interface")
	if Input.is_action_pressed("left") or interface.left:
		dir -= 1
		$Sprite2D.flip_h = true
	if Input.is_action_pressed("right") or interface.right:
		dir += 1
		$Sprite2D.flip_h = false
	if dir != 0:
		velocity.x = lerpf(velocity.x, dir * speed, acceleration)
	else:
		velocity.x = lerpf(velocity.x, 0, friction)


func _physics_process(delta):
	if !start:
		return
	if slime_detector.is_colliding():
		if slime_detector.get_collider().is_in_group("Enemy"):
			slime_detector.get_collider().destroy()

	set_health(clamp(health + (recovery_time * delta), 0, max_health))

	get_input()

	velocity.y += gravity * delta
	set_velocity(velocity)
	set_up_direction(Vector2.UP)
	move_and_slide()

	if is_on_floor() and jump_started:
		animation_player.play("land")
		if play_on_land:
			$bounce.play()
		jump_started = false
		jump_count = 0

	if !is_on_floor():
		jump_started = true
	else:
		$Residue.start()

	if Input.is_action_just_pressed("jump") or interface.jump:
		interface.jump = false
		jump()


func jump():
	if is_on_floor() or !$Residue.is_stopped():
			if jump_count < 1:
				velocity.y = jump_speed
				jump_count += 1
				jump_started = true


func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	if anim_name == "land":
		animation_player.play("Idle")
