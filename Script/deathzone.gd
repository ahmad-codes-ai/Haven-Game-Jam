extends Area2D

func _ready() -> void:
	# Automatically connects the signal so you don't have to wire it manually
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	# Checks if the object that fell in is your player
	if body is CharacterBody2D:
		get_tree().call_deferred("reload_current_scene")
