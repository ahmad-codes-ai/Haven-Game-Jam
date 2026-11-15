extends CharacterBody2D

@export_enum("Right:1", "Left:-1") var facing_direction: int = 1
@export var max_health: int = 2
@export var damage: int = 1
@export var score_value: int = 100
@export var chase_speed: float = 200.0
@export var ray_distance: float = 300.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var raycast: RayCast2D = $RayCast2D
@onready var hitbox: Area2D = $Hitbox

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var health: int
var is_chasing: bool = false
var target_player: Node2D = null

func _ready() -> void:
	add_to_group("enemy")
	health = max_health
	sprite.flip_h = (facing_direction < 0)
	raycast.target_position = Vector2(ray_distance * facing_direction, 0.0)
	hitbox.body_entered.connect(_on_hitbox_body_entered)

func take_damage(amount: int = 1) -> void:
	health -= amount
	if health <= 0:
		ScoreManager.add_score(score_value)
		queue_free()

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta

	if raycast.is_colliding():
		var collider: Object = raycast.get_collider()
		if collider is CharacterBody2D and not collider.is_in_group("enemy"):
			is_chasing = true
			target_player = collider as Node2D

	if is_chasing and is_instance_valid(target_player):
		var direction: float = signf(target_player.global_position.x - global_position.x)
		if direction != 0.0:
			velocity.x = direction * chase_speed
			sprite.flip_h = (direction < 0.0)
			raycast.target_position.x = ray_distance * direction
	else:
		velocity.x = 0.0

	move_and_slide()

	for body in hitbox.get_overlapping_bodies():
		if body is CharacterBody2D and not body.is_in_group("enemy"):
			if body.has_method("take_damage"):
				body.take_damage(damage)

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D and not body.is_in_group("enemy"):
		if body.has_method("take_damage"):
			body.take_damage(damage)
