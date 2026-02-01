class_name AudioManager extends Node

static func play_sound(sfx: AudioStream, owner: Node2D):
	var audioPlayer = AudioStreamPlayer2D.new()
	audioPlayer.global_position = owner.global_position
	audioPlayer.stream = sfx
	audioPlayer.play()
	await audioPlayer.finished
	audioPlayer.queue_free()
