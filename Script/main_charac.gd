extends CharacterBody2D

@export var speed: float = 300.0
@export var jump_velocity: float = -400.0

@onready var sprite: Sprite2D = $Sprite2D

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta: float) -> void:
	# 1. Apply Gravity
	if not is_on_floor():
		velocity.y += gravity * delta

	# 2. Handle Jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	# 3. Get Left/Right Input
	var direction := Input.get_axis("left", "right")
	
	# 4. Move and Flip Sprite
	if direction != 0:
		velocity.x = direction * speed
		sprite.flip_h = (direction < 0)
	else:
		velocity.x = move_toward(velocity.x, 0, speed)

	move_and_slide()
