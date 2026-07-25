extends Area2D

signal goal_reached(goal_id: int)

@export var goal_id: int = 0


func _ready() -> void:
    body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
    if body is CharacterBody2D:
        goal_reached.emit(goal_id)