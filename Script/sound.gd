extends Node

@export var sound_effect: AudioStream
@export_range(-40.0, 20.0) var volume_db: float = 0.0

func _ready() -> void:
	if sound_effect == null:
		return

	var player := AudioStreamPlayer.new()
	player.stream = sound_effect
	player.volume_db = volume_db
	add_child(player)
	player.play()
