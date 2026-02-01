extends AnimatedSprite2D

const constZOffset = 100

func _process(delta):
	z_index = global_position.y + constZOffset
