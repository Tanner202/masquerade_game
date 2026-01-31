class_name DialogueOption extends Button

@export var dialogue_owner: NPC
@export var next_dialogue = ""
@export var suspicion_impact := 0

func _on_pressed() -> void:
	# TODO: Impact suspicion
	dialogue_owner.move_dialogue(next_dialogue)
	print("selected dialogue")
	#var next_dialogue_instance = next_dialogue.instantiate()
	#get_tree().root.add_child(next_dialogue_instance)
