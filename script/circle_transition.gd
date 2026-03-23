extends CanvasLayer

@onready var color_rect: ColorRect = $ColorRect
@onready var shader_material := color_rect.material as ShaderMaterial

func _ready():
	color_rect.visible = false
	shader_material.set_shader_parameter("radius", 1.0)


# Call this from doors
func start_transition(target_scene: String):
	color_rect.visible = true
	shader_material.set_shader_parameter("radius", 1.0)
	
	var tween = create_tween()
	# Shrink circle to center over 0.5 seconds
	tween.tween_property(shader_material, "shader_parameter/radius", 0.0, 0.5)
	tween.tween_callback(func():
		_change_scene(target_scene)
	)


func _change_scene(target_scene: String):
	# Change the scene
	get_tree().change_scene_to_file(target_scene)
	
	# Expand circle back
	shader_material.set_shader_parameter("radius", 0.0)
	var tween = create_tween()
	tween.tween_property(shader_material, "shader_parameter/radius", 1.0, 0.5)
