extends CharacterBody2D


@export var JUMP_HOLD_MAX = 0.5
@export var JUMP_VELOCITY = 2400
@export var JUMP_HOLD_VELOCITY = 120
@export var COYOTE_SECONDS = 0.5
@export var GRAVITY = 200
@export var DOWN_PRESS_MULT = 0.25
@export var FALL_TIME_MULT = 4
@export var FALL_TIME_MAX = 3
@export var WALK_SPEED_MULT = 2
@export var WALK_SPEED_MAX = 400
@export var DECELERATION_SPEED = 10
@export var DOWN_PRESS_MAX = 0.5
@export var WALK_TIME_MAX = 0.5

var current_coyote = 0
var just_fell = false
var down_pressed = 1
var fall_time = 0
var walk_time = 1

func _physics_process(delta: float) -> void:
	if current_coyote-1 >= 0:
		current_coyote-=1
	if not is_on_floor() and not just_fell and current_coyote == 0:
		current_coyote = seconds_to_phys_frames(COYOTE_SECONDS)
		just_fell = true

	if Input.is_action_pressed("player_down") and down_pressed+1 <= seconds_to_phys_frames(DOWN_PRESS_MAX):
		down_pressed+=1
		print(down_pressed)
	if not Input.is_action_pressed("player_down") and down_pressed-1 >= 1:
		down_pressed-=1
		print(down_pressed)

	if is_on_floor():
		fall_time = 0
		if down_pressed-1 >= 1:
			down_pressed-=1
		just_fell = false
	
	if not is_on_floor():
		if fall_time+1 <= seconds_to_phys_frames(FALL_TIME_MAX):
			fall_time += 1
		velocity.y = GRAVITY * fall_time*FALL_TIME_MULT * delta * (down_pressed*DOWN_PRESS_MULT)
	# Handle jump.
	if Input.is_action_just_pressed("player_jump") and (is_on_floor() or current_coyote > 0) and just_fell == false:
		velocity.y -= JUMP_VELOCITY
		
		just_fell = true;
	
	if(just_fell) and Input.is_action_pressed("player_jump") and fall_time <= seconds_to_phys_frames(JUMP_HOLD_MAX):
		velocity.y -= JUMP_HOLD_VELOCITY
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("player_left", "player_right")
	if direction:
		if walk_time+1 <= seconds_to_phys_frames(WALK_TIME_MAX):
			walk_time += 1
		velocity.x = direction * clamp(walk_time*WALK_SPEED_MULT, 0, WALK_SPEED_MAX)
	else:
		walk_time = 0
		velocity.x = move_toward(velocity.x, 0, DECELERATION_SPEED)


	move_and_slide()

func seconds_to_phys_frames(seconds):
	return seconds * 60
