extends CharacterBody2D

# === MOVEMENT CONSTANTS ===
const SPEED = 100.0
const JUMP_VELOCITY = -300.0
const GRAVITY = 1000.0
const FALL_MULTIPLIER := 1.8

# === PUSH CONSTANTS ===
const PUSH_FORCE = 20
const BLOCK_MAX_VELOCITY = 180

# === GIANT STATE ===
var is_giant := false
var giant_timer := 0.0
const GIANT_DURATION := 10.0
const GIANT_SCALE := Vector2(2.5, 2.5)
const NORMAL_SCALE := Vector2(1, 1)

# === STATUS AND HEALTH ===
var health = 5
var isAlive: bool = true
var isTakingDamage: bool = false

# === NODES ===
@onready var animated_sprite = $AnimatedSprite2D
@onready var jump_audio: AudioStreamPlayer2D = $jumpAudio
@onready var hurt_audio: AudioStreamPlayer2D = $hurtAudio
@onready var die_audio: AudioStreamPlayer2D = $dieAudio

func _physics_process(delta: float) -> void:
	# === GRAVITY ===
	if not is_on_floor():
		if velocity.y > 0:
			velocity.y += GRAVITY * FALL_MULTIPLIER * delta
		else:
			velocity.y += GRAVITY * delta

	# === GIANT TIMER ===
	if is_giant:
		giant_timer -= delta
		if giant_timer <= 0:
			_shrink_back()

	# === JUMP ===
	if Input.is_action_just_pressed("P2-up") and is_on_floor() and !isTakingDamage:
		jump_audio.play()
		velocity.y = JUMP_VELOCITY

	# === DAMAGE FREEZE ===
	if isTakingDamage:
		velocity.x = 0
		velocity.y = 0

	# === MOVEMENT ===
	var direction := Input.get_axis("P2-left", "P2-right")
	if not isTakingDamage:
		if direction:
			velocity.x = direction * SPEED
			animated_sprite.play("run")
			animated_sprite.flip_h = direction < 0
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			animated_sprite.play("idle")

	# === PUSH BOXES ===
	move_and_slide()
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collision_block = collision.get_collider()
		if collision_block and collision_block.is_in_group("pushables") and abs(collision_block.get_linear_velocity().x) < BLOCK_MAX_VELOCITY:
			collision_block.apply_central_impulse(collision.get_normal() * -PUSH_FORCE)

# === GIANT STATE ===
func become_giant():
	if is_giant:
		giant_timer = GIANT_DURATION
		return
	is_giant = true
	giant_timer = GIANT_DURATION
	scale = GIANT_SCALE

func _shrink_back():
	is_giant = false
	giant_timer = 0.0
	scale = NORMAL_SCALE

# === DAMAGE ===
func take_damage(damage):
	if isTakingDamage or not isAlive:
		return
	if is_giant:
		return  # giant Arthur is immune to damage
	isTakingDamage = true
	health -= damage
	if health <= 0:
		isAlive = false
		die_audio.play()
		animated_sprite.play("die")
	else:
		hurt_audio.play()
		animated_sprite.play("hurt")

func knockback(force: float, direction: Vector2):
	if is_giant:
		return  # giant Arthur ignores knockback
	velocity = direction.normalized() * force

func game_over():
	get_tree().reload_current_scene()

# === ANIMATION FINISHED ===
func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite.animation == "hurt":
		isTakingDamage = false
	elif animated_sprite.animation == "die":
		game_over()
