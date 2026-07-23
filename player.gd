extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const COYOTE_FRAMES = 10
var current_coyote = 0
var just_fell = false

func _physics_process(delta: float) -> void:
	if current_coyote-1 >= 0:
		current_coyote-=1
	if not is_on_floor() and not just_fell:
		current_coyote = COYOTE_FRAMES
		just_fell = true

	if is_on_floor():
		just_fell = false
	# Handle jump.
	if Input.is_action_just_pressed("player_jump") and (is_on_floor() or current_coyote > 0):
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
