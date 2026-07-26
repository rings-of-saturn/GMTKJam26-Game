extends Area2D

@onready var tile: RigidBody2D = get_parent()


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if not body.has_method("_jump"):
		return
	if body.is_attacking:
		tile.destroy()
	if tile.kills_player and not tile.freeze and tile.linear_velocity.y > 50.0:
		LevelManager.restart_level()
