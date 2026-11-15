extends BaseButton

@export_file("*.tscn", "*.scn") var fallback_scene: String


func _ready() -> void:
	pressed.connect(_on_pressed)


func _on_pressed() -> void:
	var last_level: String = get_tree().get_meta("last_level", "")
	
	if not last_level.is_empty():
		get_tree().change_scene_to_file(last_level)
	elif not fallback_scene.is_empty():
		get_tree().change_scene_to_file(fallback_scene)
	else:
		push_warning("No previous level recorded and no fallback scene set on: " + name)
