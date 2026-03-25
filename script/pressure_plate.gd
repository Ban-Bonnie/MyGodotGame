extends Area2D

signal plate_activated
signal plate_deactivated

@export var requires_both: bool = false
@export var plate_id: String = ""
@export var one_shot: bool = false

enum State { IDLE, PRESSED, LOCKED }

var state = State.IDLE
var bodies_inside: Array = []

const VALID_GROUPS = ["players", "pushables", "enemies"]

@onready var anim: AnimatedSprite2D = $sprite
@onready var audio = $AudioStreamPlayer2D

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

	if one_shot and plate_id != "" and GameManager.collected_orbs.has("plate_" + plate_id):
		state = State.LOCKED
		anim.play("pressed")

func _is_valid_body(body) -> bool:
	for group in VALID_GROUPS:
		if body.is_in_group(group):
			return true
	return false

func _on_body_entered(body):
	if _is_valid_body(body):
		bodies_inside.append(body)
		_evaluate_state()

func _on_body_exited(body):
	if _is_valid_body(body):
		bodies_inside.erase(body)
		_evaluate_state()

func _evaluate_state():
	# LOCKED = done forever, ignore everything
	if state == State.LOCKED:
		return

	var should_activate = false

	if requires_both:
		var player_count = bodies_inside.filter(func(b): return b.is_in_group("players")).size()
		should_activate = player_count >= 2
	else:
		should_activate = bodies_inside.size() >= 1

	if should_activate:
		_press()
	else:
		_release()

func _press():
	if state == State.IDLE:
		anim.play("pressed")
		if audio:
			audio.play()
		plate_activated.emit()  # emits ONCE here
		print("Plate activated")

		if one_shot:
			state = State.LOCKED  # no more signals ever
			if plate_id != "":
				GameManager.collected_orbs["plate_" + plate_id] = true
		else:
			state = State.PRESSED

func _release():
	if state == State.PRESSED:
		state = State.IDLE
		anim.play("idle")
		plate_deactivated.emit()
		print("Plate released")
