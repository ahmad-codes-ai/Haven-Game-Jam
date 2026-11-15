extends CharacterBody2D

@export var max_health: int = 2
@export var chase_speed: float = 200.0
@export var ray_distance: float = 300.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var raycast: RayCast2D = $RayCast2D

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var health: int
var is_chasing: bool = false
var target_player: Node2D = null

func _ready() -> void:
	add_to_group("enemy")
	health = max_health
	raycast.target_position = Vector2(ray_distance, 0)

func take_damage(amount: int = 1) -> void:
	health -= amount
	if health <= 0:
		queue_free()

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta

	if raycast.is_colliding():
		var collider = raycast.get_collider()
		if collider is CharacterBody2D and not collider.is_in_group("enemy"):
			is_chasing = true
			target_player = collider

	if is_chasing and is_instance_valid(target_player):
		var direction = sign(target_player.global_position.x - global_position.x)
		if direction != 0:
			velocity.x = direction * chase_speed
			sprite.flip_h = (direction < 0)
			raycast.target_position.x = ray_distance * direction
	else:
		velocity.x = 0

	move_and_slide()

	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider is CharacterBody2D and not collider.is_in_group("enemy"):
			get_tree().call_deferred("reload_current_scene")
			break
