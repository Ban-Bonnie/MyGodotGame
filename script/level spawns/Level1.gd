extends Node2D


func _ready():
	#PLayers Spawn Anchor
	var spawn_id = GameManager.last_door_used
	
	if spawn_id == "":
		return
	var spawn_node = get_node_or_null("PlayerSpawn_" + spawn_id)
	
	if spawn_node == null:
		print("Spawn not found: ", spawn_id)
		return
	
	var players = get_tree().get_nodes_in_group("players")
	
	for i in range(players.size()):
		var offset = Vector2(20 * i, 0) # prevents overlap
		players[i].global_position = spawn_node.global_position + offset
		
	#Despawning Collected Orbs

	
	
	
func _process(delta: float) -> void:
	pass
