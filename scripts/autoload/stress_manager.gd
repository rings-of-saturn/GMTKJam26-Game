extends Node

enum StressPhase {
	CALM,
	TENSE,
	WORRIED,
	ANXIOUS,
	STRESSED,
}

signal time_changed(remaining)
signal stress_phase_changed(phase: StressPhase)
signal timer_expired()
signal toggle_countdown(new_value : bool)

@export var level_time = 120

var time_remaining = 0
var current_phase: StressPhase = StressPhase.CALM

var timer: Timer
var running = false

func _ready() -> void:
	timer = Timer.new()
	timer.wait_time = 1.0
	timer.timeout.connect(self._on_tick)
	add_child(timer)
	time_remaining = level_time


func start(duration = -1) -> void:
	if duration > 0:
		level_time = duration

	if level_time > 0:
		time_remaining = level_time
		current_phase = StressPhase.CALM
		running = true
		timer.start()
		time_changed.emit(time_remaining)
		stress_phase_changed.emit(current_phase)
	else:
		running = false
		timer.stop()
		time_changed.emit(0)

func stop() -> void:
	running = false
	timer.stop()    


func reset() -> void:
	stop()
	start()    

func get_stress_percent() -> float:
	if level_time == 0:
		return 0.0
	return float(time_remaining) / float(level_time)
	
func _on_tick() -> void:
	if not running:
		return

	time_remaining -= 1
	time_changed.emit(time_remaining)

	if time_remaining <= 0:
		running = false
		timer.stop()
		_update_phase(StressPhase.STRESSED)
		timer_expired.emit()
		return

	var pct = get_stress_percent()
	var new_phase: StressPhase

	if pct <= 0.25:
		new_phase = StressPhase.ANXIOUS
	elif pct <= 0.5:
		new_phase = StressPhase.WORRIED
	elif pct <= 0.75:
		new_phase = StressPhase.TENSE
	else:
		new_phase = StressPhase.CALM

	_update_phase(new_phase)


func _update_phase(phase: StressPhase) -> void:
	if phase != current_phase:
		current_phase = phase
		stress_phase_changed.emit(current_phase)
