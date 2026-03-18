extends AnimatedSprite2D
var player_count = 0
var door_is_open = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("players"):
		player_count +=1
		#print("Player in door area")
	if player_count ==2:
		play("open")
		door_is_open = true
		next_scene()
		
func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("players"):
		player_count -=1
		#print("Player exit door area")
	if player_count <2 and door_is_open == true:
		play("close")
		door_is_open = false

func next_scene():
	pass
