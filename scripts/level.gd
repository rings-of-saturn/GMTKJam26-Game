extends Node2D

func _ready() -> void:
	StressManager.stress_phase_changed.connect(_on_phase)

func _on_phase(phase: StressManager.StressPhase) -> void:
	match phase:
		StressManager.StressPhase.CALM:
			pass
		StressManager.StressPhase.TENSE:
			pass  # TODO: Whatever its suppose to do
		StressManager.StressPhase.WORRIED:
			pass  # TODO: Whatever its suppose to do
		StressManager.StressPhase.ANXIOUS:
			pass  # TODO: Whatever its suppose to do
		StressManager.StressPhase.STRESSED:
			pass  # handled by _on_stressed
