extends CanvasLayer

@onready var rect: ColorRect = $ColorRect

var target_opacity: float = 0.0
var transition_active: bool = false
var locked: bool = false

func _ready() -> void:
	rect.modulate = Color(0, 0, 0, 0)
	StressManager.stress_phase_changed.connect(_on_phase)


func _on_phase(phase: StressManager.StressPhase) -> void:
	if locked or transition_active:
		return
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


func transition_to(target_color: Color, duration: float) -> void:
	transition_active = true

	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(rect, "modulate:r", target_color.r, duration)
	tween.tween_property(rect, "modulate:g", target_color.g, duration)
	tween.tween_property(rect, "modulate:b", target_color.b, duration)
	tween.tween_property(rect, "modulate:a", target_color.a, duration)
	await tween.finished
	transition_active = false


func _process(delta: float) -> void:
	if locked or transition_active:
		return
	rect.modulate.a = move_toward(rect.modulate.a, target_opacity, delta * 2.0)


func lock() -> void:
	locked = true


func unlock() -> void:
	locked = false
