extends AnimatedSprite2D

@onready var cast_area: AnimatedSprite2D = $"." 
@onready var press_key_guide: AnimatedSprite2D = $pressKeyGuide

#signals
signal activate_magic(index:int)
@export var activate_platform_index: int

func _ready() -> void:
	press_key_guide.visible = true
	press_key_guide.modulate.a = 0.0  # start fully transparent
	

func _process(delta: float) -> void:
	pass


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("magic users"):
		cast_area.z_index = 4
		cast_area.stop()
		body.insideMagicCircle = true
		press_key_guide.visible = true
		var tween = create_tween()
		tween.tween_property(press_key_guide, "modulate:a", 1.0, 0.5) # fade in
		
		
		
func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("magic users"):
		var tween = create_tween()
		body.insideMagicCircle = false
		tween.tween_property(press_key_guide, "modulate:a", 0.0, 0.5) # fade out
		tween.tween_callback(func(): press_key_guide.visible = false)
		cast_area.z_index = 6
		cast_area.play("default")
	

#Merlin Successful Chant
func _on_merlin_body_skill_cast() -> void:
	activate_magic.emit(activate_platform_index)
	destroy()
	
	pass # Replace with function body.

func destroy():
	cast_area.visible=false
	pass
