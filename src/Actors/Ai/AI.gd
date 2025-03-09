extends CharacterBody2D


@export var max_health: int = 100
@export var recovery_time: int = 5 #Health per second
@export var speed: int = 300
@export var jump_speed: int = -800
@export var gravity: int = 2000
@export var friction = 0.2 # (float, 0, 1.0)
@export var acceleration = 0.3 # (float, 0, 1.0)

var start = false
var in_air = false
var play_on_land = false
var drowning = false
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var damage_interval: Timer = $DamageInterval

# AI settings

@onready var farward_raycast: RayCast2D = $"%ObstacleAhed"
@onready var below_detector: RayCast2D = $"%BelowDetector"
@onready var jump_detector: Node2D = $"%JumpDetector"
@onready var floor_detector: RayCast2D = $"%FloorDetector"
@onready var behind_detector: RayCast2D = $"%BehindDetector"
@onready var drown_detector: RayCast2D = $"%DrownDetector"

@onready var tell_jump: RayCast2D = $"%TellJump"
@onready var speech_anim: AnimationPlayer = $"%SpeechAnim"


var player: CharacterBody2D
var general_direction = 1
var water_ahed = false
var obstacle_ahed = false
var large_obstacle = false
var small_platform = false
var old_player_position :Vector2

# Stages
var jumping_platform = false
var bored = false
var make_way = false
var speech_displayed = false


# Health options
var health = 10
signal health_changed

func _ready() -> void:
	# wait for interface to start
	await get_tree().process_frame
	player = get_tree().current_scene.find_child("Player")
	var interface = get_tree().current_scene.find_child("Interface")
	var _err = health_changed.connect(interface.ai_health_changed)
	set_health(max_health)


func get_current_state():
	var data = {
		"position" :position,
		"velocity" : velocity,
		"health" : health,
		"general_direction" : general_direction,
		"temp_switch" : !$SmallTimeTurn.is_stopped(),
		"temp_switch_left" : $SmallTimeTurn.time_left,
		"in_air" : in_air,
		"play_on_land" : play_on_land,
		"drowning" : drowning,
		"water_ahed" : water_ahed,
		"obstacle_ahed" : obstacle_ahed,
		"large_obstacle" : large_obstacle,
		"small_platform" : small_platform,
		"jumping_platform" : jumping_platform,
		"bored" : bored,
		"make_way" : make_way,
		"speech_displayed" : speech_displayed,
	}
	return data


func update_data(data):
	position = data.position
	velocity = data.velocity
	health = data.health
	if general_direction != data.general_direction:
		general_direction = data.general_direction
		switch_direction()

	in_air = data.in_air
	play_on_land = data.play_on_land
	drowning = data.drowning
	water_ahed = data.water_ahed
	obstacle_ahed = data.obstacle_ahed
	large_obstacle = data.large_obstacle
	small_platform = data.small_platform
	jumping_platform = data.jumping_platform
	bored = data.bored
	make_way = data.make_way
	speech_displayed = data.speech_displayed

	if data.temp_switch:
		$SmallTimeTurn.start(data.temp_switch_left)


func set_health(value):
	if health != value:
		health = value
		emit_signal("health_changed", health)


func take_damage(value):
	if damage_interval.is_stopped():
		set_health(health - value)
		damage_interval.start()
		$HitFlash.play("Hit")


func get_input():
	play_on_land = (velocity.length() > 300)
	var dir: int = 0
	dir = general_direction

	# Obstacle detection
	large_obstacle = false
	obstacle_ahed = false
	if farward_raycast.is_colliding():
		dir = 0
		if !farward_raycast.get_collider().is_in_group("Player"):
			obstacle_ahed = true
			# tell player to jump
			if tell_jump.is_colliding():
				if !tell_jump.get_collider().is_in_group("Player"):
					large_obstacle = true
		#can turn?
		if behind_detector.is_colliding():
			# change direction if path ended
			if (
				!behind_detector.get_collider().is_in_group("Player")
				and !make_way
			):
				switch_direction()
		if farward_raycast.get_collider().is_in_group("Player"):
			# change direction if player is in the way
			$SmallTimeTurn.start(0.2)
			switch_direction()
			make_way = true

	if (player.position.x < position.x + 50
	and player.position.x > position.x - 50
	and player.position.y > position.y):
		if !jumping_platform:
			dir = 0


	# Water detection
	if below_detector.is_colliding():
		# water ahed but no player then stop
		if below_detector.get_collider().is_in_group("Water"):
			dir = 0
			water_ahed = true

		# jump on player if it's in water
		elif below_detector.get_collider().is_in_group("Player"):
			dir = general_direction
			if water_ahed:
				water_ahed = false
				small_platform = true

		elif below_detector.get_collider().is_in_group("Jump"):
			if below_detector.get_collider().jump_if_ai_moves == 0:
				if sign(below_detector.get_collider().position.x - position.x) == 1:
					dir = general_direction
					small_platform = true
			elif below_detector.get_collider().jump_if_ai_moves == 1:
				if sign(below_detector.get_collider().position.x - position.x) == -1:
					dir = general_direction
					small_platform = true
			else:
				dir = general_direction
				small_platform = true

		else:
			dir = general_direction

		drowning =false
		if drown_detector.is_colliding():
			if drown_detector.get_collider().is_in_group("Water"):
				drowning = true
			elif drown_detector.get_collider().is_in_group("Player"):
				water_ahed = false
			elif drown_detector.get_collider().is_in_group("Enemy"):
				take_damage(35)

	# Pitfall detection
	else:
		var can_jump_pit = false
		for raycast in jump_detector.get_children():
			if raycast.is_colliding():
				if raycast.get_collider().is_in_group("Floor"):
					if is_on_floor():
						small_platform = true
						can_jump_pit = true
		if !can_jump_pit:
			small_platform = false
			if !jumping_platform:
				dir = 0

	#Floor detector during jump
		if floor_detector.is_colliding():
			if jumping_platform:
				dir = 0

	# Velocity added (everytime)
	if dir != 0:
		velocity.x = lerpf(velocity.x, dir * speed, acceleration)
	else:
		velocity.x = lerpf(velocity.x, 0, friction)


func _physics_process(delta):
	if start:
		get_input()
		pop_text()

		if Input.is_action_just_pressed("switch"):
			switch_direction()

	set_health(clamp(health + (recovery_time * delta), 0, max_health))

	if general_direction == -1:
		$Sprite2D.flip_h = true
	elif general_direction == 1:
		$Sprite2D.flip_h = false

	velocity.y += gravity * delta
	if bored:
		velocity.x = 0
	set_velocity(velocity)
	set_up_direction(Vector2.UP)
	move_and_slide()

	if is_on_floor(): # reset jump settings if they are done
		if in_air:
			animation_player.play("land")
			if play_on_land:
				$bounce.play()
			in_air = false
		jumping_platform = false
	else:
		in_air = true

	# Condition to initiate jump

	if obstacle_ahed:
		if general_direction == 1:
			if player.position.x > position.x + 50:
				obstacle_ahed = false
				jump()
		else:
			if player.position.x < position.x - 50:
				obstacle_ahed = false
				jump()
	elif small_platform:
		small_platform = false
		water_ahed = false
		jumping_platform = true
		jump()


func pop_text():
	if bored:
		if !speech_displayed:
			speech_anim.play("open_bored")
			speech_displayed = true
	elif large_obstacle and !bored:
		if !speech_displayed:
			speech_anim.play("open_jump")
			speech_displayed = true
	elif water_ahed and !bored and !drowning:
		if !speech_displayed:
			speech_anim.play("open_swim")
			speech_displayed = true
	elif drowning:
		if !speech_displayed:
			speech_anim.play("open_drown")
			speech_displayed = true
		take_damage(10)
	else:
		speech_anim.play("RESET")
		reset_speech_player()


func reset_speech_player():
	speech_displayed = false


func jump():
	if is_on_floor():
		velocity.y = jump_speed


func switch_direction(_dummy = null):
	if general_direction == 1:
		general_direction = -1
		$Sensors.scale.x = -1
	elif general_direction == -1:
		general_direction = 1
		$Sensors.scale.x = 1
	obstacle_ahed = false


func _on_SmallTimeTurn_timeout() -> void:
	if make_way:
		switch_direction()
		make_way = false


func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	if anim_name == "land":
		animation_player.play("Idle")


func _on_bored_timeout() -> void:
	reset_speech_player()
	if old_player_position.distance_to(player.position) < 5:
		if position.distance_to(player.position) < 100:
			bored = true
			jump()
	else:
		bored = false
	old_player_position = player.position
