class_name DialogueOption extends Button

@export var dialogue_owner: NPC
@export var next_dialogue = ""
@export var suspicion_impact := 0

func _on_pressed() -> void:
	dialogue_owner.move_dialogue(next_dialogue)
