class_name AudioManager extends Node

const MAIN_THEME = preload("res://Audio/maintheme.wav")
const BALLROOM = preload("res://Audio/ballroom.wav")

func _ready() -> void:
	if get_tree().current_scene.name == "Level":
		play_music(MAIN_THEME)
	get_tree().scene_changed.connect(_on_scene_changed)

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
	
func _on_scene_changed():
	var scene = get_tree().current_scene
	if scene.name == "Ballroom":
		play_music(BALLROOM)
	else:
		play_music(MAIN_THEME)
