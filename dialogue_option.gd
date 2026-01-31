class_name DialogueOption extends Button

@export var next_dialogue: PackedScene
@export var suspicion_impact := 0

func _on_pressed() -> void:
	# TODO: Impact suspicion
	print("selected dialogue")
	#var next_dialogue_instance = next_dialogue.instantiate()
	#get_tree().root.add_child(next_dialogue_instance)
