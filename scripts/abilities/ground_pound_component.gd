extends Node

enum PoundState { IDLE, ACTIVE, COOLDOWN, LANDED }

@export var pound_min_speed = 350.0
@export var pound_max_speed = 1200.0
@export var pound_extra_accel = 3000.0
@export var bounce_mult = 0.25
@export var bounce_cap = -30000.0
@export var cooldown_time = 1.5

var state: PoundState = PoundState.IDLE
var cooldown_timer = 0.0
var should_bounce = false
var bounce_speed = 0.0

@onready var player: CharacterBody2D = get_parent()
@onready var cards: Node = player.get_node_or_null("Cards")


func _ready() -> void:
	if cards and cards.has_signal("first_card_used"):
		cards.first_card_used.connect(_on_pound_used)


func _physics_process(delta: float) -> void:
	cooldown_timer = maxf(cooldown_timer - delta, 0.0)

	# Handle pending bounce BEFORE any physics this frame
	if should_bounce:
		print("[POUND] APPLYING BOUNCE: ", bounce_speed, " | velocity was: ", player.velocity.y)
		should_bounce = false
		player.velocity.y = bounce_speed
		player.max_fall_current = player.MAX_FALL
		player.is_attacking = false
		state = PoundState.COOLDOWN
		cooldown_timer = cooldown_time
		return

	if state != PoundState.ACTIVE:
		return

	player.max_fall_current = pound_max_speed
	player.velocity.y += pound_extra_accel * delta
	if player.velocity.y > pound_max_speed:
		player.velocity.y = pound_max_speed

	# Landing — queue bounce for NEXT physics frame
	if player.is_on_floor():
		var speed: float = player.pre_move_velocity_y  
		bounce_speed = maxf(-speed * sqrt(bounce_mult), bounce_cap)
		print("[POUND] LANDED! speed=", speed, " | bounce=", bounce_speed, " | mult=", bounce_mult)
		should_bounce = true
		state = PoundState.LANDED


func _on_pound_used(_card_ref: Texture2D) -> void:
	if player.is_on_floor():
		return
	if state == PoundState.COOLDOWN and cooldown_timer > 0.0:
		return
	if state == PoundState.ACTIVE:
		return
	state = PoundState.ACTIVE
	player.is_attacking = true

	if player.velocity.y < pound_min_speed:
		player.velocity.y = pound_min_speed
