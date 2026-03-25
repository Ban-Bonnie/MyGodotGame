extends AnimatedSprite2D

# Audios
@onready var orb_sound_1: AudioStreamPlayer2D = $OrbCollected1
@onready var orb_sound_2: AudioStreamPlayer2D = $OrbCollected2

@export var orb_id : String

var is_collected = false


func _ready() -> void:
	self.animation_finished.connect(Callable(self, "_on_animation_finished"))
	
	if orb_id == "":
		print("Missing orb ID")
	#Destroy Orb if already Collected/Recorded
	if GameManager.collected_orbs.has(orb_id):
		queue_free()
		

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("magic users") and body.is_in_group("players") and is_collected == false:
		body.orb_collected()
		play("collected")
		is_collected = true
		
		# optional: play sound
		orb_sound_1.play() # or orb_sound_2.play()
		
		#Permanently mark orb as collected
		record_orb_collected()
		

func _on_animation_finished():
	queue_free()

func record_orb_collected():
	GameManager.collected_orbs[orb_id] = true
