extends Node

enum PoundState { IDLE, ACTIVE, COOLDOWN }

@export var pound_min_speed = 350.0      
@export var pound_max_speed = 1200.0     
@export var pound_extra_accel = 3000.0   
@export var bounce_mult = 5
@export var bounce_cap = -1000.0           
@export var cooldown_time = 0.5           

var state: PoundState = PoundState.IDLE
var cooldown_timer = 0.0

@onready var player: CharacterBody2D = get_parent()
@onready var cards: Node = player.get_node_or_null("Cards")


func _ready() -> void:
	if cards and cards.has_signal("first_card_used"):
		cards.first_card_used.connect(_on_pound_used)


func _physics_process(delta: float) -> void:
	cooldown_timer = maxf(cooldown_timer - delta, 0.0)

	if state != PoundState.ACTIVE:
		return

	player.max_fall_current = pound_max_speed

	# Extra downward acceleration on top of normal gravity
	player.velocity.y += pound_extra_accel * delta
	if player.velocity.y > pound_max_speed:
		player.velocity.y = pound_max_speed

	await get_tree().physics_frame

	if state != PoundState.ACTIVE:
		return

	if player.is_on_floor():
		_on_landing()



func _on_pound_used(_card_ref: Texture2D) -> void:
	if player.is_on_floor():
		return                              # only usable in air
	if state == PoundState.COOLDOWN and cooldown_timer > 0.0:
		return                              # cooldown active
	if state == PoundState.ACTIVE:
		return                              # already pounding

	state = PoundState.ACTIVE
	player.is_attacking = true

	# Punch downward (keep existing speed if already faster)
	if player.velocity.y < pound_min_speed:
		player.velocity.y = pound_min_speed


func _on_landing() -> void:

	var speed := player.velocity.y
	player.velocity.y = maxf(-speed * bounce_mult, bounce_cap)
	player.max_fall_current = player.MAX_FALL
	player.is_attacking = false

	state = PoundState.COOLDOWN
	cooldown_timer = cooldown_time

	await get_tree().create_timer(cooldown_time).timeout
	if state == PoundState.COOLDOWN:
		state = PoundState.IDLE
