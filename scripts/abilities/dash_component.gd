extends Node

enum DashState { 
	IDLE, 
	FREEZE, 
	ACTIVE }


@export var dash_speed: float = 240.0
@export var dash_time: float = 0.15
@export var end_dash_speed: float = 160.0
@export var end_dash_up_mult: float = 0.75      
@export var dash_cooldown: float = 0.2
@export var dash_freeze_time: float = 0.05       
@export var dash_slide_mult: float = 1.2          
@export var super_jump_h_mult: float = 1.25       
@export var wall_jump_h_speed: float = 130.0      
@export var wall_jump_y_speed: float = -105.0     
@export var wall_check_dist: int = 6              
@export var air_dash_only: bool = false




var dashes: int = 1
var max_dashes: int = 1
var dash_state: DashState = DashState.IDLE
var dash_dir: Vector2 = Vector2.ZERO
var dash_timer: float = 0.0
var freeze_timer: float = 0.0
var cooldown_timer: float = 0.0
var pending_dash_speed: Vector2 = Vector2.ZERO
var before_dash_speed: Vector2 = Vector2.ZERO


@onready var player: CharacterBody2D = get_parent()
@onready var cards: Node = player.get_node_or_null("Cards")
@onready var sprite: AnimatedSprite2D = player.get_node_or_null("AnimatedSprite2D")

func _ready() -> void:
	if cards and cards.has_signal("second_card_used"):
		cards.second_card_used.connect(_on_dash_used)

func _process(delta: float) -> void:
	cooldown_timer = maxf(cooldown_timer - delta, 0.0)

	if player.is_on_floor() and dash_state == DashState.IDLE:
		dashes = max_dashes

	match dash_state:
		DashState.FREEZE:
			freeze_timer -= delta
			player.velocity = Vector2.ZERO
			if freeze_timer <= 0.0:
				dash_state = DashState.ACTIVE
				player.velocity = pending_dash_speed
				_apply_dash_slide()

		DashState.ACTIVE:
			dash_timer -= delta
			player.velocity = dash_dir * dash_speed
			_handle_dash_jump()
			if dash_timer <= 0.0:
				_end_dash()

func _on_dash_used(_card_ref: Texture2D) -> void:
	if  dashes <= 0 or cooldown_timer > 0.0:
		return
	if air_dash_only and player.is_on_floor():
		return
	dashes -= 1
	_perform_dash()


func _perform_dash() -> void:
	var aim: Vector2 = Vector2(
		Input.get_axis("player_left", "player_right"),
		Input.get_axis("player_up", "player_down")
	)
	if aim == Vector2.ZERO:
		aim = Vector2.RIGHT if (sprite and sprite.flip_h) else Vector2.LEFT

	dash_dir = aim.normalized()
	before_dash_speed = player.velocity

	var new_speed := dash_dir * dash_speed
	if signf(before_dash_speed.x) == signf(new_speed.x) and absf(before_dash_speed.x) > absf(new_speed.x):
		new_speed.x = before_dash_speed.x

	pending_dash_speed = new_speed
	dash_timer = dash_time
	freeze_timer = dash_freeze_time
	cooldown_timer = dash_cooldown
	dash_state = DashState.FREEZE

	if dash_dir.x != 0.0 and sprite:
		sprite.flip_h = dash_dir.x > 0.0

func _apply_dash_slide() -> void:
	if player.is_on_floor() and dash_dir.x != 0.0 and dash_dir.y > 0.0:
		dash_dir.y = 0.0
		player.velocity.x *= dash_slide_mult


func _handle_dash_jump() -> void:
	if not Input.is_action_just_pressed("player_jump"):
		return

	var wall := 0
	if _check_wall(1):
		wall = 1
	elif _check_wall(-1):
		wall = -1

	if dash_dir.x != 0.0 and dash_dir.y == 0.0:
		if wall != 0:
			_wall_jump_cancel(-wall)
		else:
			_cancel_dash_with_jump(super_jump_h_mult)
	elif dash_dir.x == 0.0 and dash_dir.y == -1.0:
		if wall != 0:
			_wall_jump_cancel(-wall)
	else:
		if wall != 0:
			_wall_jump_cancel(-wall)

func _cancel_dash_with_jump(h_mult: float) -> void:
	dash_state = DashState.IDLE
	player.velocity.y = wall_jump_y_speed
	player.velocity.x *= h_mult


func _wall_jump_cancel(dir: int) -> void:
	dash_state = DashState.IDLE
	player.velocity.x = wall_jump_h_speed * dir
	player.velocity.y = wall_jump_y_speed

func _check_wall(dir: int) -> bool:
	var space_state := player.get_world_2d().direct_space_state
	var query := PhysicsRayQueryParameters2D.create(
		player.global_position,
		player.global_position + Vector2(dir * wall_check_dist, 0),
		1
	)
	query.exclude = [player]
	return space_state.intersect_ray(query).size() > 0

func _end_dash() -> void:
	dash_state = DashState.IDLE
	if dash_dir.y <= 0.0:
		var end_speed := dash_dir * end_dash_speed
		if dash_dir.y < 0.0:
			end_speed.y *= end_dash_up_mult
		player.velocity = end_speed
