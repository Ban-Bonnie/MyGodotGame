extends CharacterBody2D

#movement constants
const SPEED = 100.0
const JUMP_VELOCITY = -300.0  
const GRAVITY = 1000.0
const FALL_MULTIPLIER := 1.8
@onready var animated_sprite = $AnimatedSprite2D 


#status and health
var health = 5
var isAlive: bool = true
var isTakingDamage: bool = false


#Push Constants
const PUSH_FORCE = 20 
const BLOCK_MAX_VELOCITY = 180

#audio
@onready var jump_audio: AudioStreamPlayer2D = $jumpAudio
@onready var hurt_audio: AudioStreamPlayer2D = $hurtAudio
@onready var die_audio: AudioStreamPlayer2D = $dieAudio


#Movement ni arturo
func _physics_process(delta: float) -> void:
	
	if not is_on_floor():
		if velocity.y > 0:
			velocity.y += GRAVITY * FALL_MULTIPLIER * delta
		else:
			velocity.y += GRAVITY * delta

# INFINITE JUMP ENABLED
# DELETE "true" AND RESTORE "is_on_floor()" TO REMOVE INFINITE JUMP
	if Input.is_action_just_pressed("P2-up") and is_on_floor() and !isTakingDamage:
		jump_audio.play()
		velocity.y = JUMP_VELOCITY
		

	
	#damage weight
	if isTakingDamage:
		velocity.x = 0
		velocity.y = 0


	var direction := Input.get_axis("P2-left", "P2-right")
	if not isTakingDamage:
		if direction:
			velocity.x = direction * SPEED
			animated_sprite.play("run")
			
			animated_sprite.flip_h = direction < 0
			
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			animated_sprite.play("idle")
	
# Push Interaction Code - crates and boxes
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collision_block = collision.get_collider()
		
		# Make sure the collider still exists
		if collision_block and collision_block.is_in_group("pushables") and abs(collision_block.get_linear_velocity().x) < BLOCK_MAX_VELOCITY:
			collision_block.apply_central_impulse(collision.get_normal() * -PUSH_FORCE)
	move_and_slide()
	

func take_damage(damage):
	if isTakingDamage or not isAlive:
		return
	isTakingDamage = true
	health -= damage
	if health <= 0:
		isAlive = false
		die_audio.play()
		animated_sprite.play("die")
		
	else:
		hurt_audio.play()
		animated_sprite.play("hurt")
		

func game_over():
	get_tree().reload_current_scene()
	pass

func knockback(force: float, direction: Vector2):
	# direction should be normalized (length = 1)
	velocity = direction.normalized() * force


func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite.animation == "hurt":
		isTakingDamage = false
	 # Replace with function body.
	
	elif animated_sprite.animation == "die":
		game_over()
