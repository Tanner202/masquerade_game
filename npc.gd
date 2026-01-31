extends Node

@onready var dialogue = $Dialogue
@export var dialogue_options: Array[Button]

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		if dialogue.visible == false:
			dialogue.visible = true
		else:
			for dialogue_option in dialogue_options:
				dialogue_option.visible = true
