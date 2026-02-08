extends CharacterBody2D

#movement constants
const SPEED = 100.0
const JUMP_VELOCITY = -300.0
const GRAVITY = 1000.0
const FALL_MULTIPLIER := 1.8
@onready var animated_sprite = $AnimatedSprite2D 

#status and health
var health = 3
var isAlive: bool = true
var isTakingDamage: bool = false


#Audios
@onready var buff_sfx: AudioStreamPlayer2D = $"buff sfx"
@onready var glorious_evolution: AudioStreamPlayer2D = $"Glorious Evolution"


#Orb variables
var orbs = 0


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		if velocity.y > 0:
			velocity.y += GRAVITY * FALL_MULTIPLIER * delta
		else:
			velocity.y += GRAVITY * delta

# INFINITE JUMP ENABLED
# DELETE "true" AND RESTORE "is_on_floor()" TO REMOVE INFINITE JUMP
	if Input.is_action_just_pressed("P1-up") and true and !isTakingDamage:
		velocity.y = JUMP_VELOCITY

		
	if isTakingDamage:
		velocity.x = 0
		velocity.y = 0
	
	var direction := Input.get_axis("P1-left", "P1-right")
	if not isTakingDamage:
		if direction:
			velocity.x = direction * SPEED
			animated_sprite.play("run")
			
			animated_sprite.flip_h = direction > 0
			
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			animated_sprite.play("idle")
	move_and_slide()

func take_damage(damage):
	if isTakingDamage or not isAlive:
		return
	isTakingDamage = true
	health -= damage
	if health <= 0:
		isAlive = false
		animated_sprite.play("die")
		
	else:
		animated_sprite.play("hurt")
		

	
func orb_collected():
	buff_sfx.play()
	orbs+=1
	print(orbs)
	if orbs==5:
		glorious_evolution.play()
		animated_sprite.play("evolution")


func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite.animation == "hurt":
		isTakingDamage = false
	
	elif animated_sprite.animation == "die":
		animated_sprite.play("die")
		game_over()
		
func game_over():
	get_tree().reload_current_scene()
	pass
	
