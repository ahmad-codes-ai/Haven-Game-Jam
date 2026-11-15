extends Area2D

@export var speed: float = 700.0
@export var bounce_speed: float = 450.0 #Speed after bouncing off a wall or enemy

var direction: int = 1
var is_enemy_bullet: bool = false
var has_bounced: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	$VisibleOnScreenNotifier2D.screen_exited.connect(queue_free)

func _physics_process(delta: float) -> void:
	position.x += speed * direction * delta

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy"):
		if is_enemy_bullet and not has_bounced:
			return
		if body.has_method("take_damage"):
			body.take_damage(1)
		else:
			body.queue_free()
		bounce_toward_player()

	elif body is CharacterBody2D:
		if is_enemy_bullet or has_bounced:
			get_tree().call_deferred("reload_current_scene")
			queue_free()
		else:
			return

	else:
		bounce_toward_player()

func bounce_toward_player() -> void:
	if has_bounced:
		queue_free()
		return

	has_bounced = true
	is_enemy_bullet = true
	speed = bounce_speed #switch to the bounced bullet speed

	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		var dir_to_player = sign(players[0].global_position.x - global_position.x)
		direction = dir_to_player if dir_to_player != 0 else -direction
	else:
		direction = -direction

	position.x += direction * 12.0
