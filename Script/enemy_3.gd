extends CharacterBody2D

@export_enum("Right:1", "Left:-1") var facing_direction: int = 1
@export var damage: int = 1
@export var score_value: int = 150
@export var move_speed: float = 160.0
@export var jump_trigger_distance: float = 140.0
@export var jump_horizontal_speed: float = 340.0
@export var jump_vertical_velocity: float = -350.0
@export var jump_cooldown: float = 1.2
@export var ray_distance: float = 300.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var raycast: RayCast2D = $RayCast2D

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var is_chasing: bool = false
var target_player: Node2D = null
var jump_timer: float = 0.0

func _ready() -> void:
	add_to_group("enemy")
	sprite.flip_v = false
	sprite.flip_h = (facing_direction < 0)
	raycast.target_position = Vector2(ray_distance * facing_direction, 0.0)

func take_damage(_amount: int = 1) -> void:
	ScoreManager.add_score(score_value)
	queue_free()

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta

	if jump_timer > 0.0:
		jump_timer -= delta

	if raycast.is_colliding():
		var collider: Object = raycast.get_collider()
		if collider is CharacterBody2D and not collider.is_in_group("enemy"):
			is_chasing = true
			target_player = collider as Node2D

	if is_chasing and is_instance_valid(target_player):
		var diff_x: float = target_player.global_position.x - global_position.x
		var dir: float = signf(diff_x)

		if is_on_floor():
			if dir != 0.0:
				sprite.flip_h = (dir < 0.0)
				raycast.target_position.x = ray_distance * dir

			if absf(diff_x) <= jump_trigger_distance and jump_timer <= 0.0:
				velocity.y = jump_vertical_velocity
				velocity.x = dir * jump_horizontal_speed
				jump_timer = jump_cooldown
			else:
				velocity.x = dir * move_speed
	elif is_on_floor():
		velocity.x = 0.0

	move_and_slide()

	for i in get_slide_collision_count():
		var collision: KinematicCollision2D = get_slide_collision(i)
		var collider: Object = collision.get_collider()
		if collider is CharacterBody2D and not collider.is_in_group("enemy"):
			if collider.has_method("take_damage"):
				collider.take_damage(damage)
			break
