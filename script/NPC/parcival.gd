extends CharacterBody2D

# === MOVEMENT / PHYSICS ===
const GRAVITY = 1000.0

@onready var animated_sprite = $AnimatedSprite2D
@onready var interaction_area: Area2D = $interaction_area  # Area2D for detecting player
@onready var space_key: AnimatedSprite2D = $AnimatedSprite2D2



# === PATROL SETTINGS ===
@export var patrol_distance: float = 150.0  # total distance to pace back and forth
@export var speed: float = 60.0

# === NPC STATES ===
enum NPCState {IDLE, PACING, FOLLOW_PLAYER, INTERACTING}
@export var start_state: NPCState = NPCState.PACING  # dropdown in inspector

var state: NPCState
var start_position: Vector2
var patrol_targets: Array = []
var current_target_index: int = 0
var player_in_range: Node = null

func _ready():
	start_position = global_position
	state = start_state

	# Setup patrol targets: left -> mid -> right
	var half = patrol_distance / 2
	patrol_targets = [
		start_position + Vector2(-half, 0),
		start_position,
		start_position + Vector2(half, 0)
	]

	# Connect interaction area signals
	if interaction_area:
		interaction_area.connect("body_entered", Callable(self, "_on_body_entered"))
		interaction_area.connect("body_exited", Callable(self, "_on_body_exited"))

func _physics_process(delta):
	# Apply gravity
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	else:
		velocity.y = 0
	
	match state:
		NPCState.IDLE:
			velocity.x = 0
			animated_sprite.play("idle")

		NPCState.PACING:
			space_key.visible = false
			_handle_patrol()

		NPCState.FOLLOW_PLAYER:
			_handle_follow_player()

		NPCState.INTERACTING:
			velocity.x = 0
			animated_sprite.play("idle")
			# Check for interact input
			if Input.is_action_just_pressed("interact"):
				_on_player_interact()

	move_and_slide()


# === PATROL LOGIC ===
func _handle_patrol():
	var target = patrol_targets[current_target_index]
	var direction = (target - global_position).normalized()
	velocity.x = direction.x * speed

	if velocity.x != 0:
		animated_sprite.play("walk")
		animated_sprite.flip_h = velocity.x < 0
	else:
		animated_sprite.play("idle")

	# Switch target if reached
	if global_position.distance_to(target) < 2:
		current_target_index = (current_target_index + 1) % patrol_targets.size()


# === FOLLOW PLAYER LOGIC ===
func _handle_follow_player():
	if player_in_range:
		var direction = player_in_range.global_position - global_position
		
		# Always try to reach player (no giving up)
		if abs(direction.x) > 2:
			velocity.x = speed * sign(direction.x)
			animated_sprite.play("walk")
			animated_sprite.flip_h = velocity.x < 0
		else:
			velocity.x = 0
			animated_sprite.play("idle")

		# Stop when close
		if global_position.distance_to(player_in_range.global_position) < 20:
			state = NPCState.INTERACTING
	else:
		# If somehow lost target, stay idle instead of snapping
		velocity.x = 0
		animated_sprite.play("idle")


# === AREA SIGNALS ===
func _on_interaction_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("players") and body.is_in_group("physical users"):
		space_key.visible = true
		player_in_range = body
		state = NPCState.FOLLOW_PLAYER
	else:
		pass
		
func _on_interaction_area_body_exited(body: Node2D) -> void:
	if state != NPCState.FOLLOW_PLAYER:
		if body == player_in_range:
			space_key.visible = false
			player_in_range = null
			state = start_state


# === INTERACT BUTTON LOGIC ===
func _on_player_interact():
	print("Dialogue triggered!")
	# After interacting, reset NPC state to default
	state = start_state
	player_in_range = null
