extends CharacterBody2D

@export var speed = 400

func get_input():
	var input_direction = Input.get_vector("left", "right", "up", "down")
	velocity = input_direction * speed

func _physics_process(delta):
	get_input()
	move_and_slide()
	
	# prevent the guy from leaving the window
	position.x = clamp(position.x, 32, 640 - 32)
	position.y = clamp(position.y, 32, 360 - 32)
