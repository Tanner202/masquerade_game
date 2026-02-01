extends CharacterBody2D

class_name Player

# Character enum for who to transform into
enum Char{NONE, BW, PL}

@export var speed = 100

var can_move = true
@onready var audioPlayer = $AudioStreamPlayer2D
var curChar : Char
var curAnimatedSprite : AnimatedSprite2D
@export var base_animated_sprite: AnimatedSprite2D
@export var bw_animated_sprite: AnimatedSprite2D
@export var pl_animated_sprite: AnimatedSprite2D

#func _input(event: InputEvent) -> void:
#	if event.is_action_pressed("stab"):
#		animated_sprite_2d.play("stab")

func playStab():
	setSpriteTo(Char.NONE)
	curAnimatedSprite.play("stab")
	await get_tree().create_timer(0.6).timeout

func setSpriteTo(transformInto : Char):
	curChar = transformInto
	base_animated_sprite.hide()
	bw_animated_sprite.hide()
	pl_animated_sprite.hide()
	if (transformInto == Char.BW):
		curAnimatedSprite = bw_animated_sprite
	elif (transformInto == Char.PL):
		curAnimatedSprite = pl_animated_sprite
	else:
		curAnimatedSprite = base_animated_sprite
	curAnimatedSprite.show()

func setSpriteToFun(transformInto : Char):
	var oldChar = curChar
	print("Start setSpriteToFun")
	setSpriteTo(transformInto)
	await get_tree().create_timer(0.1).timeout
	setSpriteTo(oldChar)
	await get_tree().create_timer(0.1).timeout
	setSpriteTo(transformInto)
	await get_tree().create_timer(0.1).timeout
	setSpriteTo(oldChar)
	await get_tree().create_timer(0.1).timeout
	setSpriteTo(transformInto)
	print("Done with setSpriteToFun")

func _ready():
	setSpriteTo(Char.NONE)
	Controller.setPlayer(self)

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
		if curAnimatedSprite.animation != "stab":
			curAnimatedSprite.stop()
	elif !audioPlayer.playing:
		audioPlayer.play()
		curAnimatedSprite.play("walk")
	
	if velocity.x > 0:
		curAnimatedSprite.flip_h = true
	elif velocity.x < 0:
		curAnimatedSprite.flip_h = false
	
	if velocity.y != 0 and velocity.x == 0:
		curAnimatedSprite.play("walk_vertical")
	elif velocity.x != 0:
		curAnimatedSprite.play("walk")
		
	get_input()
	move_and_slide()
