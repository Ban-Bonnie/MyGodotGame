extends StaticBody2D

# === SIGNALS ===
signal boss_defeated

# === HP ===
@export var max_hp := 10
var hp := 10

# === DEMONS ===
@export var demon_scene: PackedScene
@export var demons_to_spawn := 3  # easily configurable
var demons_alive := 0

# === PROXIMITY KNOCKBACK ===
@export var knockback_range := 80.0
@export var knockback_force := 600.0

# === NODES ===
@onready var sprite: AnimatedSprite2D = $FlameDemonBoss
@onready var summon_point_l: Marker2D = $SummonPointL
@onready var summon_point_r: Marker2D = $SummonPointR

# === STATE ===
enum BossState { IDLE, SUMMONING, WAITING, STUNNED, HURT, DEAD }
var state := BossState.IDLE

# === STUN ===
var stun_timer := 0.0
@export var stun_duration := 8.0

func _ready():
	sprite.animation_finished.connect(_on_animation_finished)
	hp = max_hp
	_start_summon()

func _physics_process(delta):
	match state:
		BossState.WAITING:
			_check_proximity()
		BossState.STUNNED:
			stun_timer -= delta
			if stun_timer <= 0:
				_end_stun()

# === PROXIMITY KNOCKBACK ===
func _check_proximity():
	var players = get_tree().get_nodes_in_group("players")
	for player in players:
		if player.is_giant:
			continue  # giant Arthur allowed close
		var dist = global_position.distance_to(player.global_position)
		if dist < knockback_range:
			var dir = (player.global_position - global_position).normalized()
			if player.has_method("knockback"):
				player.knockback(knockback_force, dir)

# === SUMMON ===
func _start_summon():
	state = BossState.SUMMONING
	sprite.play("rage")  # rage animation = summoning

func _spawn_demons():
	demons_alive = demons_to_spawn
	for i in demons_to_spawn:
		var demon = demon_scene.instantiate()
		get_parent().add_child(demon)
		if i % 2 == 0:
			demon.global_position = summon_point_l.global_position
		else:
			demon.global_position = summon_point_r.global_position
		demon.tree_exited.connect(_on_demon_died)
	state = BossState.WAITING
	sprite.play("idle")

func _on_demon_died():
	demons_alive -= 1
	print("demons left: ", demons_alive)
	if demons_alive <= 0:
		print("all demons dead — Merlin can now cast spell")

# === STUN (called by Merlin spell) ===
func enter_stun():
	if state != BossState.WAITING:
		return
	state = BossState.STUNNED
	stun_timer = stun_duration
	sprite.play("idle")  # just holds idle while stunned, swap if you get a stun anim

func _end_stun():
	if state == BossState.DEAD:
		return
	# Arthur didn't stomp in time — back to summoning
	state = BossState.WAITING
	sprite.play("idle")

# === TAKE DAMAGE (giant Arthur stomp only) ===
func take_damage(damage):
	if state != BossState.STUNNED:
		return
	hp -= damage
	print("boss hp: ", hp)

	if hp <= 0:
		_die()
		return

	state = BossState.HURT
	sprite.play("hurt")

# === DEATH ===
func _die():
	state = BossState.DEAD
	sprite.play("die")
	boss_defeated.emit()

# === ANIMATION FINISHED ===
func _on_animation_finished():
	match sprite.animation:
		"rage":
			_spawn_demons()
		"hurt":
			# after hurt, rage again and spawn more demons
			_start_summon()
		"die":
			queue_free()
