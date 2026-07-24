extends Node2D

func _ready() -> void:
	StressManager.stress_phase_changed.connect(_on_phase)
	StressManager.timer_expired.connect(_on_stressed)
	StressManager.start()


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


func _on_stressed() -> void:
	# TODO: Death
	pass    
