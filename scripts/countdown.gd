extends Sprite2D

var _label: RichTextLabel


func _ready() -> void:
	_label = get_node("RichTextLabel")
	StressManager.time_changed.connect(_on_time_changed)
	# Show initial time in case start() hasn't fired yet
	_on_time_changed(StressManager.time_remaining)


func _on_time_changed(remaining) -> void:
	var minutes = remaining / 60
	var seconds = remaining % 60
	_label.text = "[color=red]%02d:%02d" % [minutes, seconds]

func _on_timer_timeout() -> void:
	pass  # kept so the scene Timer node doesn't error;
