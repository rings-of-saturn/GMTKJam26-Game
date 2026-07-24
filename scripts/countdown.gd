extends Sprite2D

@export var TIMER_MAX = 120

var timer
var text
var time_passed = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	timer = get_node("Timer")
	timer.timeout.connect(_on_timer_timeout)
	text = get_node("RichTextLabel")


# Called every frame. 'delta' i	s the elapsed time since the previous frame.
func _process(delta: float) -> void:
	text.text = turn_timer_to_text(TIMER_MAX, time_passed)
	
	
	
func _on_timer_timeout():
	time_passed += 1

func turn_timer_to_text(timer_max, current_time):
	var return_text = ""
	var modified_time = timer_max - current_time
	var minutes = 0
	if(seconds_to_minutes(modified_time)):
		minutes = seconds_to_minutes(modified_time)
	var seconds = modified_time
	if(seconds_to_minutes(modified_time)):
		seconds = modified_time - (seconds_to_minutes(modified_time)*60)
	
	var minutes_0 = ""
	if(minutes < 10):
		minutes_0 = "0"
		
	var seconds_0 = ""
	if(seconds < 10):
		seconds_0 = "0"
	
	return_text = "[color=red]" + minutes_0 + "%s[b]:[/b]" % minutes + seconds_0 + "%s" % seconds
	
	return return_text
	
func seconds_to_minutes(seconds):
	if(seconds % 60):
		return floor(seconds/60)
