extends CharacterBody2D

# === PHYSICS ===
const GRAVITY = 1000.0

# === MOVEMENT ===
@export var move_speed := 40.0
var direction := -1


# === HEALTH ===
@export var max_hp := 1
var hp := 1

# === PATROL TYPE ===
enum PatrolType {WALL, EDGE}
@export var patrol_type: PatrolType = PatrolType.WALL

# === NODES ===
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hurtbox: Area2D = $hurtbox
@onready var body_collision: CollisionShape2D = $body
@onready var ground_check: RayCast2D = $ground_check


# === STATE ===
enum EnemyState {PATROL, ATTACK, HURT, DEAD}
var state = EnemyState.PATROL
var is_dead := false


func _ready():
	hp = max_hp
	sprite.connect("animation_finished", Callable(self, "_on_animation_finished"))
	print(hp)

func _physics_process(delta): 
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	else:
		velocity.y = 0

	match state:
		EnemyState.PATROL:
			_handle_patrol(true)
			
		EnemyState.ATTACK:
			velocity.x = 0
			
		EnemyState.HURT:
			velocity.x = 0
			
		EnemyState.DEAD:
			velocity = Vector2.ZERO

	move_and_slide()


# === PATROL LOGIC ===
func _handle_patrol(force_animation: bool = false):
	velocity.x = move_speed * direction
	
	if force_animation or sprite.animation != "walk":
		sprite.play("walk")

	sprite.flip_h = direction > 0

	# --- WALL MODE ---
	if patrol_type == PatrolType.WALL:
		if is_on_wall() and velocity.x != 0:
			_flip_direction()

	# --- EDGE MODE ---
	elif patrol_type == PatrolType.EDGE:
		# Update ray direction
		ground_check.target_position = Vector2(12 * direction, 20)

		# Debug (optional)
		# print(ground_check.is_colliding())

		if is_on_floor() and not ground_check.is_colliding():
			_flip_direction()
# === PLAYER INTERACTION ===
func _on_hurtbox_body_entered(body):
	# Only interact with players, pushables, or boxes
	if not body.is_in_group("players") and not body.is_in_group("pushables") and not body.is_in_group("boxes"):
		return

	# --- STRICT STOMP CHECK ---
	var vertical_check = body.global_position.y < global_position.y - 10
	var horizontal_distance = abs(body.global_position.x - global_position.x)
	var horizontal_threshold = 12.0
	var is_centered = horizontal_distance < horizontal_threshold

	var is_above = vertical_check and is_centered

	if is_above:
		if body.is_in_group("players"):
			# Player stomping enemy
			print("STOMP! Player bounces")
			hp -= 1
			
			print(body.has_method("knockback"))
			
			if body.has_method("knockback"):
				body.knockback(250, Vector2.UP)

			if hp <= 0:
				state = EnemyState.DEAD
				die()
			else:
				state = EnemyState.HURT
				sprite.play("hurt")

		elif body.is_in_group("boxes"):
			# Box hits enemy from above
			print("BOX HEAD HIT!")
			hp -= 10  # box damage

			if hp <= 0:
				state = EnemyState.DEAD
				die()
			else:
				state = EnemyState.HURT
				sprite.play("hurt")

	else:
		# Enemy attacks player or box normally
		print("Attack hit!")

		# Face the target before attacking
		if body.global_position.x > global_position.x:
			direction = 1
		else:
			direction = -1
		sprite.flip_h = direction > 0

		state = EnemyState.ATTACK
		sprite.play("attack")

		# Apply damage if the object has a take_damage method
		if body.has_method("take_damage"):
			body.take_damage(1)

		# Apply damage if the object has a take_damage method
		if body.has_method("take_damage"):
			body.take_damage(1)


# === ANIMATION FINISHED ===
func _on_animation_finished():
	if state == EnemyState.ATTACK or state == EnemyState.HURT:
		state = EnemyState.PATROL
	elif state == EnemyState.DEAD:
		queue_free()


# === DEATH ===
func die():
	is_dead = true

	body_collision.set_deferred("disabled", true)
	hurtbox.set_deferred("monitoring", false)

	velocity = Vector2.ZERO
	sprite.play("die")

#== HELPER FUNCTION===
func _flip_direction():
	direction *= -1
	velocity.x = move_speed * direction
