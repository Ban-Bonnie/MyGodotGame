extends Camera2D

@export var move_speed = 30      # Camera position lerp speed
@export var zoom_speed = 3.0     # Camera zoom lerp speed
@export var min_zoom = 5.0       # Camera won't zoom closer than this
@export var max_zoom = 0.5       # Camera won't zoom farther than this
@export var margin = Vector2(400, 200)  # Buffer area around targets

var targets: Array[CharacterBody2D] = []

@onready var screen_size = get_viewport_rect().size

func _ready():
	# Type-safe assignment: only add CharacterBody2D nodes from "players" group
	targets.clear()
	for node in get_tree().get_nodes_in_group("players"):
		if node is CharacterBody2D:
			targets.append(node)

func add_target(t):
	if t and t not in targets:
		targets.append(t)

func remove_target(t):
	if t in targets:
		targets.erase(t)

func _process(delta):
	if not targets:
		return

	# Compute average position of all valid targets
	var p = Vector2.ZERO
	var valid_targets = 0
	for target in targets:
		if is_instance_valid(target):
			p += target.global_position
			valid_targets += 1

	if valid_targets == 0:
		return  # Nothing to track

	p /= valid_targets
	position = lerp(position, p, move_speed * delta)

	# Compute a rectangle that contains all valid targets
	var r = Rect2(p, Vector2.ONE)
	for target in targets:
		if is_instance_valid(target):
			r = r.expand(target.global_position)
	
	r = r.grow_individual(margin.x, margin.y, margin.x, margin.y)

	# Determine zoom to fit all targets on screen
	var _z
	if r.size.x > r.size.y * screen_size.aspect():
		_z = 1 / clamp(r.size.x / screen_size.x, min_zoom, max_zoom)
