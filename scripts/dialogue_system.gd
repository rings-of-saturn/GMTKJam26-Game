class_name DialogueSystem
extends Node2D

@onready var text: RichTextLabel = $RichTextLabel
@onready var sprite: TextureRect = $TextureRect

const DEV_TALK_SPRITE = preload("uid://02igcrchlbce")
const PLAYER_TALK_SPRITE = preload("uid://dtdmngby5meus")

@export var text_display_remainder : int
@export var text_fade_remainder : int

var text_display_time : int
var delay : int
var i = 0
var text_fade_time: int

func _physics_process(delta: float) -> void:
	if text_display_time < 0 and text_display_time-1 >= 0:
		text_display_time-1
	else:
		visible = false
		
	if delay < 0 and delay-1 >= 0:
		delay-1
	else:
		i+= 1
	
func show_line(new_text : String, character_name : String):
	visible = true
	text_display_time = text_display_remainder * 60
	text.text = new_text
	print(text.text)

func show_dialogue(dialogue : DialogueLine):
	if(delay == 0) and i+1 <= dialogue.text.size():
		show_line(dialogue.text[i], dialogue.character_name[i])
		delay = text_display_remainder + dialogue.delay[i]

func name_to_sprite(character_name : String):
	if character_name.to_lower() == "dev":
		return DEV_TALK_SPRITE
	if character_name.to_lower() == "player":
		return PLAYER_TALK_SPRITE
