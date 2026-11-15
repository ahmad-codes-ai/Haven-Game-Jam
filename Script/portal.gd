extends Area2D

@export_file("*.tscn") var next_level_path: String

var is_transitioning: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if is_transitioning:
		return
	if body.is_in_group("player"):
		if next_level_path.is_empty():
			push_warning("Level portal has no next_level_path assigned!")
			return
		is_transitioning = true
		get_tree().call_deferred("change_scene_to_file", next_level_path)
