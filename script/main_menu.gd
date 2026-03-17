extends Node2D


func _on_play_pressed() -> void:
	print("Start pressed")
	get_tree().change_scene_to_file("res://scenes/World Scenes/MainScene.tscn")



func _on_settings_pressed() -> void:
	print("settings pressed")
	pass # Replace with function body.


func _on_quit_pressed() -> void:
	print("quit pressed")
	get_tree().quit()
