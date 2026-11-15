extends Control
@export var final_score_label: Label

func _ready() -> void:
	if final_score_label != null:
		final_score_label.text = "Total Score: %d" % ScoreManager.score
