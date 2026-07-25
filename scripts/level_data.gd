extends Node2D

## Map goal_id → level_index.
## Leave empty for linear progression (defaults to next level).
@export var routes: Dictionary = {
    # 0: 1,   # goal 0 → level index 1
    # 1: 3,   # goal 1 → level index 3
}

func _ready() -> void:
    for child in _find_goal_areas(self):
        child.goal_reached.connect(_on_goal_reached)


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