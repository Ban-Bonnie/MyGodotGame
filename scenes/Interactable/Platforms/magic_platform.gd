extends AnimatableBody2D

var activated = false
@export var platform_index: int
@export var animation_name: String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	

func activate_platform():
	var anim = get_node_or_null("AnimationPlayer")
	if anim:
		anim.play(animation_name)

func deactivate_platform():
	var anim = get_node_or_null("AnimationPlayer")
	if anim:
		anim.stop()

func _on_cast_area_activate_magic(index: int) -> void:
	print("Signal received")
	if index == platform_index:
		activate_platform()
		pass # Replace with function body.
