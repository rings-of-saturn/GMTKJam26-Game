extends Node

enum GameState {
	PLAYING,
	LEVEL_COMPLETE,
	STRESSED,
	DIALOG,
	# TODO Add future state ( CUTSCENE, PAUSED, DIALOG, GAME_OVER)
}
@export var level_list: Array[String] = [
	"res://scenes/level_4.tscn",
	"res://scenes/level_1.tscn",
	"res://scenes/level_2.tscn",
	"res://scenes/level_3.tscn",
	"res://scenes/level_4.tscn",
	"res://scenes/level_5.tscn",
	"res://scenes/level_6.tscn",
	# TODO Put more level
]

var current_level_index = 0
var state: GameState = GameState.PLAYING
var level_slot: Node2D
var current_level: Node
var time_limit: int = 120


func _ready() -> void:
	StressManager.timer_expired.connect(_on_timer_expired)
	_load_initial.call_deferred()




func _load_initial() -> void:
	var slots := get_tree().get_nodes_in_group("level_slot")
	if slots.size() == 0:
		return
	level_slot = slots[0]
	load_level(0)

func load_level(index: int) -> void:
	if index < 0 or index >= level_list.size():
		return

	current_level_index = index

	if current_level:
		level_slot.remove_child(current_level)
		current_level.queue_free()

	var packed: PackedScene = load(level_list[index])
	current_level = packed.instantiate()
	level_slot.add_child(current_level)
	current_level.owner = level_slot.owner

	time_limit = current_level.get("time_limit") if current_level.get("time_limit") else 120
	StressManager.start(time_limit)
	state = GameState.PLAYING
	_spawn_player()

func _spawn_player() -> void:
	var player := level_slot.get_node_or_null("../Player") as CharacterBody2D
	if not player:
		return

	var spawn := current_level.get_node_or_null("SpawnPoint") as Marker2D
	if not spawn:
		return

	player.global_position = spawn.global_position

func next_level() -> void:
	if current_level_index + 1 < level_list.size():
		load_level(current_level_index + 1)
	else:
		_on_game_complete()

func restart_level() -> void:
	load_level(current_level_index)

func on_level_complete(target: int = -1) -> void:
	if state != GameState.PLAYING:
		return

	StressManager.stop()
	state = GameState.LEVEL_COMPLETE
	if target >= 0:
		load_level.bind(target).call_deferred()
	else:
		next_level.call_deferred()

func _on_timer_expired() -> void:
	StressManager.stop()
	state = GameState.STRESSED
	await get_tree().create_timer(1.0).timeout
	restart_level()                          


func _on_game_complete() -> void:
	print("GAME COMPLETE")
