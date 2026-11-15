extends CharacterBody2D

@export var speed: float = 300.0
@export var jump_velocity: float = -400.0
@export var bullet_scene: PackedScene #drag bullet.tscn into this slot in the Inspector!

@onready var sprite: Sprite2D = $Sprite2D
@onready var muzzle: Marker2D = $GunMuzzle

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var facing_direction: int = 1
var muzzle_offset_x: float

func _ready() -> void:
	#remember the gun barrel's starting X distance from the player's center
	muzzle_offset_x = abs(muzzle.position.x)

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	var direction := Input.get_axis("left", "right")
	
	if direction != 0:
		velocity.x = direction * speed
		facing_direction = int(sign(direction))
		sprite.flip_h = (facing_direction < 0)
		#flip the gun muzzle position to match the direction the player faces
		muzzle.position.x = muzzle_offset_x * facing_direction
	else:
		velocity.x = move_toward(velocity.x, 0, speed)

	if Input.is_action_just_pressed("shoot"):
		shoot()

	move_and_slide()

func shoot() -> void:
	if bullet_scene == null:
		return
	var bullet = bullet_scene.instantiate()
	bullet.global_position = muzzle.global_position
	bullet.direction = facing_direction
	get_tree().current_scene.add_child(bullet)
