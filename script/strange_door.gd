extends StaticBody2D

enum State { CLOSED, OPENING, OPEN, CLOSING }
enum Direction { LEFT, RIGHT }

@export var facing: Direction = Direction.LEFT

var state = State.CLOSED
var is_held: bool = false  # tracks if plate is still being pressed

@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var audio: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var sprite: AnimatedSprite2D = $"strange door"

func _ready():
	sprite.animation_finished.connect(_on_animation_finished)
	if facing == Direction.RIGHT:
		sprite.flip_h = true

func activate():
	if state != State.CLOSED:
		return
	is_held = true
	state = State.OPENING
	sprite.play("open")
	if audio:
		audio.play()

func deactivate():
	is_held = false
	# if already open, close immediately
	if state == State.OPEN:
		state = State.CLOSING
		sprite.play("close")
		if audio:
			audio.play()
	# if still opening, _on_animation_finished will handle it

func _on_animation_finished():
	if sprite.animation == "open":
		if is_held:
			state = State.OPEN
			collision.set_deferred("disabled", true)
		else:
			state = State.CLOSING
			sprite.play("close")
			if audio:
				audio.play()

	elif sprite.animation == "close":
		state = State.CLOSED
		collision.set_deferred("disabled", false)
		sprite.play("idle")

func _on_pressure_plate_plate_activated():
	activate()

func _on_pressure_plate_plate_deactivated():
	deactivate()

func _on_button_pressed():
	activate()

func _on_button_released():
	deactivate()

func _on_pressure_plate_2_plate_activated():
	activate()

func _on_pressure_plate_2_plate_deactivated():
	deactivate()
