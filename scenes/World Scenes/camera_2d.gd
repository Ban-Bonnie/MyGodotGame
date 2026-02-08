extends Camera2D

# Assign characters
@onready var arthur_body: CharacterBody2D = $"../../ArthurBody"
@onready var merlin_body: CharacterBody2D = $".."

# Camera settings
@export var min_zoom: float = 1.0        # Closest zoom
@export var max_zoom: float = 3.0        # Farthest zoom
@export var zoom_distance_ref: float = 400.0  # Distance at which zoom = 1
@export var smooth_speed: float = 0.1    # How fast the camera follows

func _ready():
	make_current()  # Godot 4 way to activate this camera

func _process(delta):
	if not arthur_body or not merlin_body:
		return  # safety check

	# 1. Midpoint between players
	var midpoint = (arthur_body.global_position + merlin_body.global_position) / 2

	# 2. Smooth camera movement
	global_position = global_position.lerp(midpoint, smooth_speed)

	# 3. Adjust zoom based on distance
	var distance = arthur_body.global_position.distance_to(merlin_body.global_position)
	var target_zoom = clamp(distance / zoom_distance_ref, min_zoom, max_zoom)
	zoom = Vector2(target_zoom, target_zoom)
