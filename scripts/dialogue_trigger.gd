class_name DialogueTrigger
extends Area2D

@export var dialogue : DialogueSet
# Triggers the dialogue only once, set it to false for Tips of helps or idk
@export var one_shot= true

var triggered = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D):
	if not body.has_method("_jump"):
		return
	if one_shot and triggered:
		return
	triggered = true
	var display := get_tree().get_first_node_in_group("dialogue_system") as DialogueSystem
	if display:
		display.show_dialogue(dialogue)
