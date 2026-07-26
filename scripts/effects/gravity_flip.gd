class_name GravityShiftTrigger
extends Area2D

@export var one_shot: bool = true

var triggered: bool = false


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if not body.has_method("_jump"):
		return
	if one_shot and triggered:
		return
	triggered = true

	var vignette := get_tree().get_first_node_in_group("vignette") as CanvasLayer
	if not vignette or not vignette.has_method("transition_to"):
		return

	body.gravity_inverted = true
	body.position.y -= 3.0

	vignette.transition_to(Color(1, 1, 1, 0.8), 1.0)
	await get_tree().create_timer(1.0).timeout

	vignette.transition_to(Color(0, 0, 0, 0.5), 1.0)
	vignette.lock()
