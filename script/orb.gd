extends AnimatedSprite2D

#Audios
@onready var orb_sound_1: AudioStreamPlayer2D = $OrbCollected1
@onready var orb_sound_2: AudioStreamPlayer2D = $OrbCollected2
 
@onready var merlin_body: CharacterBody2D = $"../../Characters/MerlinBody"
@onready var static_body_2d: StaticBody2D = $StaticBody2D

# Flash effect variables
@export var flash_color: Color = Color(1, 0.2, 0.2)
@export var flash_duration: float = 0.3  # time to reach red
@export var hold_duration: float = 1.0   # how long to stay red
@export var return_duration: float = 0.3 # time to return to original
var original_color: Color
var flash_timer: float = 0.0
var flash_phase := "idle"  # "to_red", "hold", "to_original"

func _ready() -> void:
	# Connect the animation_finished signal correctly - idk this line but ig it works
	self.animation_finished.connect(Callable(self, "_on_animation_finished"))
	original_color = modulate
	
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("magic users") and body.is_in_group("players"):
		
		merlin_body.orb_collected() 
		play("collected")
		self.queue_free()
	elif body.is_in_group("players") and not body.is_in_group("magic users"):
		flash_timer = 0.0
		flash_phase = "to_red"
		
	else: 
		pass

func _process(delta):
	if flash_phase == "to_red":
		flash_timer += delta
		modulate = original_color.lerp(flash_color, clamp(flash_timer / flash_duration, 0, 1))
		if flash_timer >= flash_duration:
			flash_timer = 0.0
			flash_phase = "hold"

	elif flash_phase == "hold":
		flash_timer += delta
		if flash_timer >= hold_duration:
			flash_timer = 0.0
			flash_phase = "to_original"

	elif flash_phase == "to_original":
		flash_timer += delta
		modulate = flash_color.lerp(original_color, clamp(flash_timer / return_duration, 0, 1))
		if flash_timer >= return_duration:
			modulate = original_color
			flash_phase = "idle"

func _on_animation_finished():
	queue_free()
 
