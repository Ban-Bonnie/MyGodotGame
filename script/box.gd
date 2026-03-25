extends RigidBody2D

# === GROUPS ===
func _ready() -> void:
	add_to_group("pushables")
	health = max_health
	can_sleep = false

# === HEALTH ===
@export var max_health := 2
var health := 2
var is_taking_damage := false
var is_alive := true

# === NODES ===
@onready var animated_sprite: AnimatedSprite2D = $Sprite2D

# === DAMAGE SYSTEM ===
func take_damage(damage):
	if is_taking_damage or not is_alive:
		return
	is_taking_damage = true
	health -= damage
	if health <= 0:
		is_alive = false
		animated_sprite.play("break")
	else:
		animated_sprite.play("hit")

# === ANIMATION FINISHED ===
func _on_sprite_2d_animation_finished() -> void:
	if not is_alive:
		queue_free()
	else:
		is_taking_damage = false
		animated_sprite.play("idle")
