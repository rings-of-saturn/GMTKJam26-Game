extends Node2D


@export var granted_cards: Array[int] = [2]
@export var removed_cards: Array[int] = []

## Level time in seconds
@export var time_limit: int = 120

## Map goal_id → level_index.
## Leave empty for linear progression (defaults to next level).
@export var routes: Dictionary = {
	# 0: 1,   # goal 0 → level index 1
	# 1: 3,   # goal 1 → level index 3
}

func _ready() -> void:
	_grant_cards()
	for child in _find_goal_areas(self):
		child.goal_reached.connect(_on_goal_reached)




func _grant_cards() -> void:
	var player := get_node("../../Player") as CharacterBody2D
	if not player:
		return
	var cards := player.get_node_or_null("Cards")
	if not cards:
		return
	for cid: int in granted_cards:
		cards.enable_card(cid)
	for cid: int in removed_cards:
		cards.disable_card(cid)


func _on_goal_reached(gid: int) -> void:
	if routes.has(gid):
		LevelManager.on_level_complete(routes[gid])
	else:
		LevelManager.on_level_complete()  # default: next level


func _find_goal_areas(root: Node) -> Array[Node]:
	var results: Array[Node] = []
	for child in root.get_children():
		if child.has_signal("goal_reached"):
			results.append(child)
		results.append_array(_find_goal_areas(child))
	return results
