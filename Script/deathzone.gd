extends Area2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		ScoreManager.reset_score()
		get_tree().call_deferred("reload_current_scene")
