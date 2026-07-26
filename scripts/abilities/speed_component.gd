extends Node2D

@onready var player: CharacterBody2D = get_parent()
@onready var cards: Node = player.get_node_or_null("Cards")
@onready var sprite: AnimatedSprite2D = player.get_node_or_null("AnimatedSprite2D")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
