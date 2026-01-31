class_name DialogueOption extends Button

@export var dialogue_owner: NPC
@export var suspicion_impact := 0

var next_dialogue = ""

func _on_pressed() -> void:
	# TODO: Impact suspicion
	dialogue_owner.move_dialogue(next_dialogue)
	print("selected dialogue")

func set_next(next: String):
	next_dialogue = next
