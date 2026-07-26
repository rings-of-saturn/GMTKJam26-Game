extends Node

@onready var camera: Camera2D = get_parent() as Camera2D

var trauma: float = 0.0


func _ready() -> void:
	StressManager.stress_phase_changed.connect(_on_phase)


func _on_phase(phase: StressManager.StressPhase) -> void:
	match phase:
		StressManager.StressPhase.CALM:
			trauma = 0.0
		StressManager.StressPhase.TENSE:
			trauma += 0.15
		StressManager.StressPhase.WORRIED:
			trauma += 0.25
		StressManager.StressPhase.ANXIOUS:
			trauma += 0.35
		StressManager.StressPhase.STRESSED:
			trauma += 0.5


func _process(delta: float) -> void:
	if trauma < 0.001:
		return

	trauma -= delta * 0.8
	var shake := trauma * trauma
	camera.offset = Vector2(
		randf_range(-shake, shake) * 12.0,
		randf_range(-shake, shake) * 8.0
	)
