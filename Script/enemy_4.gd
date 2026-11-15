extends CharacterBody2D

@export var damage: int = 1
@export var score_value: int = 200

@export_group("Roaming Area")
@export var roam_width: float = 250.0
@export var roam_height: float = 120.0
@export var roam_speed: float = 100.0

@export_group("Chasing")
@export var fly_speed: float = 220.0

@onready var sprite: Sprite2D = $Sprite2D

var start_position: Vector2
var roam_target: Vector2
var raycasts: Array[RayCast2D] = []
var is_chasing: bool = false
var target_player: Node2D = null
var facing_dir: int = 1

func _ready() -> void:
	add_to_group("enemy")
	start_position = global_position

	for node in find_children("*", "RayCast2D", true, false):
		if node is RayCast2D:
			raycasts.append(node)

	pick_new_roam_target()

func take_damage(_amount: int = 1) -> void:
	ScoreManager.add_score(score_value)
	queue_free()

func _physics_process(_delta: float) -> void:
	if not is_chasing:
		for ray in raycasts:
			if ray.is_colliding():
				var collider: Object = ray.get_collider()
				if collider is CharacterBody2D and not collider.is_in_group("enemy"):
					is_chasing = true
					target_player = collider as Node2D
					break

	if is_chasing and is_instance_valid(target_player):
		var dir: Vector2 = (target_player.global_position - global_position).normalized()
		velocity = dir * fly_speed
		update_facing(dir.x)
	else:
		var to_target: Vector2 = roam_target - global_position
		if to_target.length() < 10.0:
			pick_new_roam_target()
		else:
			var dir: Vector2 = to_target.normalized()
			velocity = dir * roam_speed
			update_facing(dir.x)

	move_and_slide()

	if not is_chasing and get_slide_collision_count() > 0:
		pick_new_roam_target()

	for i in get_slide_collision_count():
		var collision: KinematicCollision2D = get_slide_collision(i)
		var collider: Object = collision.get_collider()
		if collider is CharacterBody2D and not collider.is_in_group("enemy"):
			if collider.has_method("take_damage"):
				collider.take_damage(damage)
			break

func pick_new_roam_target() -> void:
	var half_w: float = roam_width * 0.5
	var half_h: float = roam_height * 0.5
	roam_target = start_position + Vector2(
		randf_range(-half_w, half_w),
		randf_range(-half_h, half_h)
	)

func update_facing(dir_x: float) -> void:
	if absf(dir_x) < 0.05:
		return
	var new_dir: int = 1 if dir_x > 0.0 else -1
	if new_dir != facing_dir:
		facing_dir = new_dir
		sprite.flip_h = (facing_dir < 0)
		for ray in raycasts:
			ray.target_position.x = absf(ray.target_position.x) * facing_dir
			ray.position.x = absf(ray.position.x) * facing_dir
