extends AnimatableBody2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer #this is the child animation player
var activated = false
var platform_index = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	

func activate_platform():
	animation_player.play("magic_platform")

func deactivate_platform():
	animation_player.stop()


func _on_cast_area_activate_magic(index: int) -> void:
	if index == platform_index:
		activate_platform()
		pass # Replace with function body.
