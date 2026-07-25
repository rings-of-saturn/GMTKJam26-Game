extends Node2D

@onready var third_sprite: Sprite2D = $"Card 3"
@onready var second_sprite: Sprite2D = $"Card 2"
@onready var first_sprite: Sprite2D = $"Card 1"

const CARD_BASE = preload("uid://8pd88rktly3w")
const CARD_SPEED = preload("uid://byixd3vivdxyr")

var current_first_card = CARD_BASE;
var current_second_card = CARD_BASE;
var current_third_card = CARD_BASE;	
var enabled_cards : Array[int]

signal first_card_used
signal second_card_used
signal third_card_used

func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#TODO: make cards easy to enable and disable
	enabled_cards.append(1)
	enabled_cards.append(2)
	
	current_second_card = CARD_SPEED;
	
	
	if not enabled_cards.has(1):
		first_sprite.visible = false
	if not enabled_cards.has(2):
		second_sprite.visible = false
	if not enabled_cards.has(3):
		third_sprite.visible = false
	first_sprite.texture = current_first_card;
	second_sprite.texture = current_second_card;
	third_sprite.texture = current_third_card;
	if enabled_cards.has(1):
		if Input.is_action_pressed("player_ability_1"):
			print("holding first card")
		if Input.is_action_just_released("player_ability_1"):
			print("used first card")
			first_card_used.emit(current_first_card)
	
	if enabled_cards.has(2):
		if Input.is_action_pressed("player_ability_2"):
			print("holding second card")
		if Input.is_action_just_released("player_ability_2"):
			print("used second card")
			second_card_used.emit(current_second_card)
	
	if enabled_cards.has(3):
		if Input.is_action_pressed("player_ability_3"):
			print("holding third card")
		if Input.is_action_just_released("player_ability_3"):
			print("used third card")
			third_card_used.emit(current_third_card)
	
