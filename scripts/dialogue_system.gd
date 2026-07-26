class_name DialogueSystem
extends CanvasLayer

signal dialogue_finished()

@onready var name_label: RichTextLabel = $MarginContainer/MarginContainer/HBoxContainer/NameLabel
@onready var text_label: RichTextLabel = $MarginContainer/MarginContainer/HBoxContainer/TextLabel
@onready var portrait: TextureRect = $MarginContainer/MarginContainer/HBoxContainer/Portrait
@onready var indicator: RichTextLabel = $MarginContainer/MarginContainer/HBoxContainer/ContinueIndicator

const DEV_TALK_SPRITE = preload("uid://3wb0sjf1s5au")
const PLAYER_TALK_SPRITE = preload("uid://dtdmngby5meus")


var queue: Array[DialogueLine] = []
var index = 0
var can_advance = false

func _ready() -> void:
	visible = false
	add_to_group("dialogue_system")

func _input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("player_ability_1") and can_advance:
		get_viewport().set_input_as_handled()
		_show_line()
	
func _show_line():
	if index >= queue.size():
		_end_dialogue()
		return

	var line := queue[index]
	can_advance = false
	indicator.hide()

	name_label.text = line.character_name
	portrait.texture = name_to_sprite(line.character_name)
	text_label.text = ""  
	await get_tree().create_timer(line.delay_before).timeout
	await _type_text(line.text, line.text_speed)

	can_advance = true
	index += 1

	if line.auto_advance > 0.0:
		indicator.show()
		await get_tree().create_timer(line.auto_advance).timeout
		if can_advance:
			_show_line()
	else:
		indicator.show()

func show_dialogue(set: DialogueSet) -> void:
	queue = set.lines.duplicate()
	index = 0
	visible = true
	LevelManager.state = LevelManager.GameState.DIALOG
	StressManager.stop() 
	_show_line()



func _type_text(text: String, speed: float) -> void:
	text_label.text = ""
	for ch in text:
		text_label.text += ch
		await get_tree().create_timer(speed).timeout

func name_to_sprite(character_name : String):
	match character_name.to_lower():
		"dev":
			return DEV_TALK_SPRITE
		"player":
			return PLAYER_TALK_SPRITE
	return DEV_TALK_SPRITE


func _end_dialogue() -> void:
	visible = false
	queue.clear()
	LevelManager.state = LevelManager.GameState.PLAYING
	StressManager.start() 
	dialogue_finished.emit()
