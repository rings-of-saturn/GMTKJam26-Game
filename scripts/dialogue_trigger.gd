class_name DialogueTrigger
extends Area2D

@export var dialogue : DialogueLine

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(_trigger_dialogue(dialogue))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _trigger_dialogue(dialogue : DialogueLine):
	DialogueSystem.show_dialogue(dialogue)
