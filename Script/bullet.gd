extends Area2D

@export var damage: int = 1
@export var speed: float = 700.0
@export var bounce_speed: float = 450.0

var direction: Variant = Vector2.RIGHT
var is_enemy_bullet: bool = false
var has_bounced: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	$VisibleOnScreenNotifier2D.screen_exited.connect(queue_free)
	if direction is int or direction is float:
		direction = Vector2(signf(float(direction)), 0.0)
	else:
		direction = (direction as Vector2).normalized()
	rotation = (direction as Vector2).angle()

func _physics_process(delta: float) -> void:
	position += (direction as Vector2) * speed * delta

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy"):
		if is_enemy_bullet and not has_bounced:
			return
		if body.has_method("take_damage"):
			body.take_damage(damage)
		else:
			body.queue_free()
		bounce_off_surface(body)
	elif body is CharacterBody2D:
		if is_enemy_bullet or has_bounced:
			if body.has_method("take_damage"):
				body.take_damage(damage)
			queue_free()
		else:
			return
	else:
		bounce_off_surface(body)

func bounce_off_surface(body: Node2D) -> void:
	if has_bounced:
		queue_free()
		return
	has_bounced = true
	is_enemy_bullet = true
	speed = bounce_speed

	var dir_vec: Vector2 = direction as Vector2
	var space_state: PhysicsDirectSpaceState2D = get_world_2d().direct_space_state
	var query: PhysicsRayQueryParameters2D = PhysicsRayQueryParameters2D.create(
		global_position - dir_vec * 20.0,
		global_position + dir_vec * 20.0
	)
	query.exclude = [self]
	var hit: Dictionary = space_state.intersect_ray(query)
	if hit.has("normal") and (hit["normal"] as Vector2) != Vector2.ZERO:
		direction = dir_vec.bounce(hit["normal"] as Vector2).normalized()
	elif is_instance_valid(body):
		var fallback_normal: Vector2 = (global_position - body.global_position).normalized()
		direction = dir_vec.bounce(fallback_normal).normalized()
	else:
		direction = -dir_vec
	rotation = (direction as Vector2).angle()
	position += (direction as Vector2) * 12.0
