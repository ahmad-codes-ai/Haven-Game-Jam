extends CharacterBody2D

@export_group("Health & Movement")
@export var max_health: int = 3
@export var invincibility_time: float = 1.0
@export var speed: float = 300.0
@export var jump_velocity: float = -400.0

@export_group("Weapon & Magazine")
@export var bullet_scene: PackedScene
@export var max_bullets: int = 10
@export var reload_time: float = 1.2
@export var auto_reload: bool = true
@export var shoot_delay: float = 0.2

@onready var sprite: AnimatedSprite2D = $Sprite2D
@onready var muzzle: Marker2D = $GunMuzzle
@onready var ammo_label: Label = $HUD/AmmoLabel
@onready var score_label: Label = $HUD/ScoreLabel

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var health: int
var current_bullets: int
var is_reloading: bool = false
var is_firing_delay: bool = false
var is_dead: bool = false
var is_playing_action: bool = false
var invincible_timer: float = 0.0
var facing_direction: int = 1
var muzzle_offset_x: float

func _ready() -> void:
	add_to_group("player")
	health = max_health
	current_bullets = max_bullets
	muzzle_offset_x = absf(muzzle.position.x)
	update_ammo_ui()

	ScoreManager.score_changed.connect(_on_score_changed)
	_on_score_changed(ScoreManager.score)

	if sprite.sprite_frames != null:
		for anim_name in ["shoot", "damage", "death"]:
			if sprite.sprite_frames.has_animation(anim_name):
				sprite.sprite_frames.set_animation_loop(anim_name, false)

	sprite.animation_finished.connect(_on_animation_finished)
	sprite.play("idle")

func _physics_process(delta: float) -> void:
	if is_dead:
		return

	if invincible_timer > 0.0:
		invincible_timer -= delta
		sprite.modulate.a = 0.4 if fmod(invincible_timer, 0.2) > 0.1 else 1.0
		if invincible_timer <= 0.0:
			sprite.modulate.a = 1.0

	if not is_on_floor():
		velocity.y += gravity * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	var direction: float = Input.get_axis("left", "right")
	
	if direction != 0.0:
		velocity.x = direction * speed
		facing_direction = int(signf(direction))
		sprite.flip_h = (facing_direction < 0)
		muzzle.position.x = muzzle_offset_x * facing_direction
	else:
		velocity.x = move_toward(velocity.x, 0.0, speed)

	if InputMap.has_action("reload") and Input.is_action_just_pressed("reload"):
		if not is_reloading and not is_firing_delay and current_bullets < max_bullets:
			start_reload()

	if Input.is_action_just_pressed("shoot"):
		shoot()

	move_and_slide()
	update_movement_animation(direction)

func update_movement_animation(direction: float) -> void:
	if is_dead or is_playing_action:
		return

	if direction != 0.0:
		if sprite.animation != "run":
			sprite.play("run")
	else:
		if sprite.animation != "idle":
			sprite.play("idle")

func _on_animation_finished() -> void:
	if sprite.animation == "death":
		ScoreManager.reset_score()
		get_tree().call_deferred("reload_current_scene")
	elif sprite.animation in ["shoot", "damage"]:
		is_playing_action = false

func take_damage(amount: int = 1) -> void:
	if invincible_timer > 0.0 or is_dead:
		return

	health -= amount
	invincible_timer = invincibility_time

	if health <= 0:
		is_dead = true
		is_playing_action = true
		velocity = Vector2.ZERO
		sprite.modulate.a = 1.0
		sprite.play("death")
	else:
		is_playing_action = true
		sprite.play("damage")

func shoot() -> void:
	if bullet_scene == null or is_reloading or is_firing_delay or is_dead:
		return

	if current_bullets <= 0:
		if auto_reload:
			start_reload()
		return

	is_firing_delay = true

	var mouse_pos: Vector2 = get_global_mouse_position()
	var aim_side: float = signf(mouse_pos.x - global_position.x)
	if aim_side != 0.0:
		facing_direction = int(aim_side)
		sprite.flip_h = (facing_direction < 0)
		muzzle.position.x = muzzle_offset_x * facing_direction

	is_playing_action = true
	sprite.frame = 0
	sprite.play("shoot")

	if shoot_delay > 0.0:
		await get_tree().create_timer(shoot_delay).timeout

	if is_dead:
		is_firing_delay = false
		return

	current_bullets -= 1
	update_ammo_ui()

	var fire_mouse_pos: Vector2 = get_global_mouse_position()
	var aim_direction: Vector2 = (fire_mouse_pos - muzzle.global_position).normalized()

	var bullet: Area2D = bullet_scene.instantiate()
	bullet.global_position = muzzle.global_position
	bullet.direction = aim_direction
	get_tree().current_scene.add_child(bullet)

	is_firing_delay = false

	if current_bullets <= 0 and auto_reload:
		start_reload()

func start_reload() -> void:
	if is_reloading:
		return
	is_reloading = true
	update_ammo_ui()
	await get_tree().create_timer(reload_time).timeout
	current_bullets = max_bullets
	is_reloading = false
	update_ammo_ui()

func update_ammo_ui() -> void:
	if ammo_label == null:
		return
	if is_reloading:
		ammo_label.text = "Reloading..."
	else:
		ammo_label.text = "Ammo: %d / %d" % [current_bullets, max_bullets]

func _on_score_changed(new_score: int) -> void:
	if score_label != null:
		score_label.text = "Score: %d" % new_score
