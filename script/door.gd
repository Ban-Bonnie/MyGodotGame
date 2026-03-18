extends Node2D

@export var target_scene: String

@export var door_id: String          # unique ID for this door
@export var target_door_id: String   # door ID in the next scene

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

# Track players safely
var players_inside: Array = []

var door_is_open = false

func _process(delta: float) -> void:
	# Only allow scene change if door is open and both players inside
	if door_is_open and players_inside.size() == 2:
		if Input.is_action_just_pressed("interact"):
			next_scene()
			


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("players") and body not in players_inside:
		players_inside.append(body)

	if players_inside.size() == 2 and !door_is_open and target_scene != "":
		animated_sprite_2d.play("open")
		door_is_open = true


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("players") and body in players_inside:
		players_inside.erase(body)

	if players_inside.size() < 2 and door_is_open:
		animated_sprite_2d.play("close")
		door_is_open = false


func next_scene():
	if target_scene != "":
		GameManager.last_door_used = target_door_id
		get_tree().change_scene_to_file(target_scene)
		print(GameManager.last_door_used)
	else:
		print("Next scene is empty")
