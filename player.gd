extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const COYOTE_FRAMES = 10
var current_coyote = 0
const GRAVITY = 200
const DOWN_PRESS_MULT = 0.25
const FALL_GRAVITY_MULT = 4
const FALL_MAX = 100
var just_fell = false
var down_pressed = 1
var fall_time = 0
const DOWN_PRESS_MAX = 30

func _physics_process(delta: float) -> void:
	if current_coyote-1 >= 0:
		current_coyote-=1
	if not is_on_floor() and not just_fell:
		current_coyote = COYOTE_FRAMES
		just_fell = true

	if Input.is_action_pressed("player_down") and down_pressed < DOWN_PRESS_MAX:
		down_pressed+=1
		print(down_pressed)
	if not Input.is_action_pressed("player_down") and down_pressed-1 >= 1:
		down_pressed-=1

	if is_on_floor():
		fall_time = 0
		if down_pressed-1 >= 1:
			down_pressed-=1
		just_fell = false
		
	if Input.is_action_pressed("player_ability_1"):
		print(delta)
	
	
	if not is_on_floor():
		fall_time += 1
		print(fall_time)
		velocity.y = GRAVITY * clamp(fall_time*FALL_GRAVITY_MULT, 0, FALL_MAX)* delta * (down_pressed*DOWN_PRESS_MULT)
	# Handle jump.
	if Input.is_action_just_pressed("player_jump") and (is_on_floor() or current_coyote > 0):
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("player_left", "player_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
