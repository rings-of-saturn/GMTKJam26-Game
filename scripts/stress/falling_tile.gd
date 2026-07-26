@tool
extends RigidBody2D

## Stress phase that triggers this tile to fall.
## CALM = fall immediately. TENSE/WORRIED/ANXIOUS/STRESSED = wait for that phase.
@export_enum("CALM", "TENSE", "WORRIED", "ANXIOUS", "STRESSED") var trigger_phase: int = 1
## Delay after trigger before gravity activates.
@export var activation_delay = 0.15

## White flash on destruction.
@export var flash_on_hit = true

## Whether this tile can be destroyed by player attacks
@export var breakable = true

## Number of hits required to destroy the tile. 1 = breaks in one hit.
@export var max_hits = 1

## Color the sprite flashes to on hit. Transient — restores to normal after.
@export var flash_color: Color = Color(0.3, 0.3, 0.3, 1)

## Duration of the flash in seconds.
@export var flash_duration: float = 0.06

## Width in 8px tile units.
@export var tile_width: int = 1

## Height in 8px tile units.
@export var tile_height: int = 1

## Extra pixels on destructible zone per side.
@export var zone_margin: float = 3.0

## If true, level restarts when this tile falls onto the player.
@export var kills_player: bool = false


var player: Node2D
var hits_remaining: int = 0

func _ready() -> void:
	hits_remaining = max_hits
	gravity_scale = 0.0
	freeze = true

	_apply_size()


	if Engine.is_editor_hint():
		return 

	call_deferred("_apply_size") 
	
	if trigger_phase == 0:
		_activate()
	else:
		StressManager.stress_phase_changed.connect(_on_phase)

func _on_phase(phase: StressManager.StressPhase) -> void:
	if phase == trigger_phase:
		_activate()
		
func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		_apply_size()
		return


func _activate() -> void:
	await get_tree().create_timer(activation_delay).timeout
	gravity_scale = 1.0
	freeze = false

func destroy() -> void:
	if not breakable:
		return
	hits_remaining -= 1
	if flash_on_hit:
		_flash()
		await get_tree().create_timer(flash_duration).timeout
	if hits_remaining <= 0:
		var sprite := get_node_or_null("Sprite2D")
		if sprite:
			var tween := create_tween()
			tween.tween_property(sprite, "scale", Vector2.ZERO, 0.1)
			tween.tween_callback(queue_free)
		else:
			queue_free()

func _flash() -> void:
	var sprite := get_node_or_null("Sprite2D") as Sprite2D
	if not sprite:
		return
	var original := sprite.modulate
	sprite.modulate = flash_color
	await get_tree().create_timer(flash_duration).timeout
	sprite.modulate = original


func _apply_size() -> void:
	var size := Vector2(tile_width * 8, tile_height * 8)

	var body_col := get_node_or_null("CollisionShape2D") as CollisionShape2D
	if body_col and body_col.shape is RectangleShape2D:
		if Engine.is_editor_hint():
			body_col.shape.size = size    
		else:
			body_col.shape = body_col.shape.duplicate()
			(body_col.shape as RectangleShape2D).size = size

	var sprite := get_node_or_null("Sprite2D") as Sprite2D
	if sprite:
		sprite.scale = Vector2(tile_width, tile_height)

	var zone_col := get_node_or_null("DestructibleZone/CollisionShape2D") as CollisionShape2D
	if zone_col and zone_col.shape is RectangleShape2D:
		if Engine.is_editor_hint():
			zone_col.shape.size = size + Vector2(zone_margin * 2, zone_margin * 2)
		else:
			zone_col.shape = zone_col.shape.duplicate()
			(zone_col.shape as RectangleShape2D).size = size + Vector2(zone_margin * 2, zone_margin * 2)
