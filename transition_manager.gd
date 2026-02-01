extends Node

var target_door: String

func _ready() -> void:
	get_tree().scene_changed.connect(_on_scene_changed)

func _on_scene_changed():
	var target_door_instance = get_tree().current_scene.get_node(target_door)
	var player = get_tree().current_scene.get_node("Player")
	if player and target_door_instance:
		player.global_position = target_door_instance.global_position
	
func set_target_door(target_door: String):
	self.target_door = target_door

func change_scene(filepath):
	get_tree().change_scene_to_file(filepath)
