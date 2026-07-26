extends Sprite2D

var label: RichTextLabel
var base_position: Vector2
var jitter: float = 0.0

func _ready() -> void:
	label = get_node("RichTextLabel")
	base_position = label.position
	StressManager.time_changed.connect(_on_time_changed)
	StressManager.stress_phase_changed.connect(_on_phase)
	_on_time_changed(StressManager.time_remaining)

func _process(_delta: float) -> void:
	if jitter > 0.0:
		label.position = base_position + Vector2(
			randf_range(-jitter, jitter),
			randf_range(-jitter, jitter)
		)

func _on_time_changed(remaining) -> void:
	var minutes = remaining / 60
	var seconds = remaining % 60
	label.text = "%02d:%02d" % [minutes, seconds]

func _on_timer_timeout() -> void:
	pass  # kept so the scene Timer node doesn't error;

func _on_phase(phase: StressManager.StressPhase) -> void:
	match phase:
		StressManager.StressPhase.CALM:
			label.modulate = Color(0.1, 0.1, 0.1) 
			jitter = 0.0
		StressManager.StressPhase.TENSE:
			label.modulate = Color(1, 0.65, 0.2)
			jitter = 1.2
		StressManager.StressPhase.WORRIED:
			label.modulate = Color(1, 0.15, 0.05)
			jitter = 2.0
		StressManager.StressPhase.ANXIOUS:
			label.modulate = Color(0.65, 0.02, 0.02)
			jitter = 4.0
		StressManager.StressPhase.STRESSED:
			label.modulate = Color(0.35, 0, 0)
			jitter = 8.0
