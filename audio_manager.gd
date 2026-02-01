class_name AudioManager extends Node

const MAINTHEME = preload("res://Audio/maintheme.wav")

func _ready() -> void:
	play_music(MAINTHEME)

func play_sound(sfx: AudioStream, owner: Node2D):
	var audioPlayer = AudioStreamPlayer2D.new()
	get_tree().root.add_child(audioPlayer)
	audioPlayer.global_position = owner.global_position
	audioPlayer.stream = sfx
	audioPlayer.play()
	await audioPlayer.finished
	audioPlayer.queue_free()

func play_music(music: AudioStream):
	var musicPlayer = AudioStreamPlayer.new()
	add_child(musicPlayer)
	musicPlayer.stream = music
	musicPlayer.play()
	
