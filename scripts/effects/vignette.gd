extends CanvasLayer

@onready var rect: ColorRect = $ColorRect

var target_opacity: float = 0.0


func _ready() -> void:
	rect.modulate = Color(0, 0, 0, 0)
	StressManager.stress_phase_changed.connect(_on_phase)


func _on_phase(phase: StressManager.StressPhase) -> void:
	match phase:
		StressManager.StressPhase.CALM:
			target_opacity = 0.0
		StressManager.StressPhase.TENSE:
			target_opacity = 0.12
		StressManager.StressPhase.WORRIED:
			target_opacity = 0.22
		StressManager.StressPhase.ANXIOUS:
			target_opacity = 0.35
		StressManager.StressPhase.STRESSED:
			target_opacity = 0.50


func _process(delta: float) -> void:
	rect.modulate.a = move_toward(rect.modulate.a, target_opacity, delta * 0.3)
