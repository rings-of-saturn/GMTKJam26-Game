extends Node2D

@onready var third_sprite: Sprite2D = $"Card 3"
@onready var second_sprite: Sprite2D = $"Card 2"
@onready var first_sprite: Sprite2D = $"Card 1"

const CARD_BASE = preload("uid://8pd88rktly3w")
const CARD_SPEED = preload("uid://byixd3vivdxyr")
const CARD_GROUNDSLAM = preload("uid://bamb6cs5iwxf5")

var current_first_card = CARD_GROUNDSLAM;
var current_second_card = CARD_SPEED;
var current_third_card = CARD_BASE;	
var enabled_cards : Array[int]

signal first_card_used
signal second_card_used
signal third_card_used

func _ready() -> void:
	first_sprite.texture = current_first_card
	second_sprite.texture = current_second_card
	third_sprite.texture = current_third_card
	_update_visibility()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if enabled_cards.has(1):
		if Input.is_action_just_pressed("player_ability_1"):
			first_card_used.emit(current_first_card)
	if enabled_cards.has(2):
		if Input.is_action_just_pressed("player_ability_2"):
			second_card_used.emit(current_second_card)
	if enabled_cards.has(3):
		if Input.is_action_just_pressed("player_ability_3"):
			third_card_used.emit(current_third_card)
	


func enable_card(card_id: int) -> void:
	if not enabled_cards.has(card_id):
		enabled_cards.append(card_id)
		_update_visibility()


func disable_card(card_id: int) -> void:
	enabled_cards.erase(card_id)
	_update_visibility()


func _update_visibility() -> void:
	first_sprite.visible = enabled_cards.has(1)
	second_sprite.visible = enabled_cards.has(2)
	third_sprite.visible = enabled_cards.has(3)
