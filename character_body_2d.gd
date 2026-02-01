extends CharacterBody2D

@export var speed = 100

var can_move = true
@onready var audioPlayer = $AudioStreamPlayer2D

func get_input():
	var input_direction = Input.get_vector("left", "right", "up", "down")
	velocity = input_direction * speed

func _physics_process(delta):
	if not can_move:
		velocity = Vector2.ZERO
		move_and_slide()
		return
	if velocity == Vector2.ZERO:
		audioPlayer.stop()
	elif !audioPlayer.playing:
		audioPlayer.play()
		
	get_input()
	move_and_slide()
