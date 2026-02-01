extends CharacterBody2D

@export var speed = 100

var can_move = true
@onready var audioPlayer = $AudioStreamPlayer2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("stab"):
		animated_sprite_2d.play("stab")

func get_input():
	var input_direction = Input.get_vector("left", "right", "up", "down")
	velocity = input_direction * speed
	animated_sprite_2d.play()

func _physics_process(delta):
	if not can_move:
		velocity = Vector2.ZERO
		move_and_slide()
		return
	if velocity == Vector2.ZERO:
		audioPlayer.stop()
		if animated_sprite_2d.animation != "stab":
			animated_sprite_2d.stop()
	elif !audioPlayer.playing:
		audioPlayer.play()
		animated_sprite_2d.play("walk")
	
	if velocity.x > 0:
		animated_sprite_2d.flip_h = true
	elif velocity.x < 0:
		animated_sprite_2d.flip_h = false
	
	if velocity.y != 0 and velocity.x == 0:
		animated_sprite_2d.play("walk_vertical")
	elif velocity.x != 0:
		animated_sprite_2d.play("walk")
		
	get_input()
	move_and_slide()
