extends Node2D

@onready var sprite: Sprite2D = $Sprite2D

@export var falling_phase : StressPhase
var should_fall = false
var shaking_frames = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	StressManager.stress_phase_changed.connect(_on_phase_changed)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if(shaking_frames > 0 and shaking_frames-1 >= 0):
		shaking_frames-=1
		sprite.
		

func _on_phase_changed(phase):
	if(phase == falling_phase):
		
		
