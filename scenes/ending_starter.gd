extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(_start_cutscene)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _start_cutscene(body):
	if body is CharacterBody2D:
		
