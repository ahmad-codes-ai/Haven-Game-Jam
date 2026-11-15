extends CharacterBody2D

@export var bullet_scene: PackedScene # Drag bullet.tscn here in the Inspector
@export var bullet_speed: float = 400.0 # Customize Enemy 2's bullet speed in the Inspector
@export var ray_distance: float = 350.0
@export var fire_cooldown: float = 1.2
@export var facing_direction: int = 1 # Set to -1 in Inspector if enemy faces left

@onready var sprite: Sprite2D = $Sprite2D
@onready var raycast: RayCast2D = $RayCast2D
@onready var muzzle: Marker2D = $GunMuzzle

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var shoot_timer: float = 0.0

func _ready() -> void:
	add_to_group("enemy")
	sprite.flip_h = (facing_direction < 0)
	raycast.target_position = Vector2(ray_distance * facing_direction, 0)
	muzzle.position.x = abs(muzzle.position.x) * facing_direction

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta

	if shoot_timer > 0.0:
		shoot_timer -= delta

	if raycast.is_colliding():
		var collider = raycast.get_collider()
		if collider is CharacterBody2D and not collider.is_in_group("enemy"):
			if shoot_timer <= 0.0:
				shoot()
				shoot_timer = fire_cooldown

	move_and_slide()

func shoot() -> void:
	if bullet_scene == null:
		return
	var bullet = bullet_scene.instantiate()
	bullet.global_position = muzzle.global_position
	bullet.direction = facing_direction
	bullet.speed = bullet_speed
	bullet.is_enemy_bullet = true
	get_tree().current_scene.add_child(bullet)
