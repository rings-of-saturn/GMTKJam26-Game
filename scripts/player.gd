extends CharacterBody2D


# Speed approached toward when falling. 
@export var MAX_FALL = 160.0

@export var GRAVITY = 900.0

# When velocity.y drops below this AND jump is held, gravity halves.
@export var HALF_GRAV_THRESHOLD = 40.0

# Terminal velocity while fast-falling (holding down).
@export var FAST_MAX_FALL = 240.0

# Approach rate toward FAST_MAX_FALL.
@export var FAST_MAX_ACCEL = 300.0

# Initial upward speed applied on jump.
@export var JUMP_SPEED = -105.0

# Extra horizontal speed added when jumping from ground. 
@export var JUMP_H_BOOST = 40.0

# Time holding jump that keeps upward speed clamped to JUMP_SPEED.
@export var VAR_JUMP_TIME = 0.2

# Time after walking off a ledge a jump still registers.
@export var JUMP_GRACE_TIME = 0.1

# Max horizontal speed. 
@export var MAX_RUN = 90.0

# Acceleration toward MAX_RUN on ground.
@export var RUN_ACCEL = 1000.0

# Deceleration when above MAX_RUN.
@export var RUN_REDUCE = 400.0

# Multiplier on RUN_ACCEL / RUN_REDUCE while airborne
@export var AIR_MULT = 0.65

# Max horizontal speed while carrying something If we include carrying idk
@export var HOLDING_MAX_RUN = 70.0

# Friction on ground while ducking. If we include ducking idk
@export var DUCK_FRICTION = 500.0

var jump_grace_timer = 0.0
var var_jump_timer= 0.0
var crouching = false;
var var_jump_speed = 0.0
var max_fall_current = MAX_FALL
var was_on_ground = false
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func _physics_process(delta) -> void:
	#crouch
	if Input.is_action_pressed("player_down") and is_on_floor() and not crouching:
		collision_shape.shape.size.y = 8
		collision_shape.position.y = 2
		crouching = true
	if not Input.is_action_pressed("player_down"):
		collision_shape.shape.size.y = 12
		collision_shape.position.y = 0
		crouching = false;
		
	# timers 
	jump_grace_timer = maxf(jump_grace_timer - delta, 0.0)
	var_jump_timer = maxf(var_jump_timer - delta, 0.0)

	# coyote
	if is_on_floor():
		jump_grace_timer = JUMP_GRACE_TIME
	else:
		jump_grace_timer = maxf(jump_grace_timer - delta, 0.0)


	was_on_ground = is_on_floor()

	# horizontal
	var direction = Input.get_axis("player_left", "player_right")
	var max_run = MAX_RUN
	var mult = 1.0 if is_on_floor() else AIR_MULT

	if absf(velocity.x) > max_run and signf(velocity.x) == direction:
		velocity.x = move_toward(velocity.x, max_run * direction, RUN_REDUCE * mult * delta)
	else:
		velocity.x = move_toward(velocity.x, max_run * direction, RUN_ACCEL * mult * delta)

	# vertical
	max_fall_current = move_toward(max_fall_current, MAX_FALL, FAST_MAX_ACCEL * delta)

	# fast-fall
	if Input.is_action_pressed("player_down") and velocity.y >= MAX_FALL:
		max_fall_current = move_toward(max_fall_current, FAST_MAX_FALL, FAST_MAX_ACCEL * delta)

	# gravity
	if not is_on_floor():
		var grav_mult = 1.0
		if absf(velocity.y) < HALF_GRAV_THRESHOLD and Input.is_action_pressed("player_jump"):
			grav_mult = 0.5
		velocity.y = move_toward(velocity.y, max_fall_current, GRAVITY * grav_mult * delta)

	# jump
	if var_jump_timer > 0.0:
		if Input.is_action_pressed("player_jump"):
			velocity.y = minf(velocity.y, var_jump_speed)
		else:
			var_jump_timer = 0.0

	if Input.is_action_just_pressed("player_jump"):
		if jump_grace_timer > 0.0:
			_jump()

	move_and_slide()
	
	#player direction(sprite)
	if(direction == 1):
		sprite.flip_h = true
	elif(direction == -1):
		sprite.flip_h = false
	if(direction):
		sprite.animation = "walk"
	elif(crouching):
		sprite.animation = "crouch"
		if(sprite.frame == 3):
			sprite.frame = 3
	elif(var_jump_timer < 0):
		sprite.animation = "jump"
	elif not is_on_floor():
		sprite.animation = "flying"
	else:
		sprite.animation = "idle"

func _jump() -> void:
	jump_grace_timer = 0.0
	var_jump_timer = VAR_JUMP_TIME
	var_jump_speed = JUMP_SPEED
	velocity.y = JUMP_SPEED
	velocity.x += JUMP_H_BOOST * Input.get_axis("player_left", "player_right")
