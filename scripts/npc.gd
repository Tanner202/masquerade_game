class_name NPC extends Node

@onready var dialogue = $Dialogue
@export var dialogue_options: Array[Button]
var dialogue_filepath = "res://dialogue.json"
var dialogue_dict: Dictionary
var current_dialogue_id = "start"

func _ready() -> void:
	dialogue_dict = read_json(dialogue_filepath)
	dialogue.text = dialogue_dict[current_dialogue_id]["text"]

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		if dialogue.visible == false:
			dialogue.visible = true
			for i in range(len(dialogue_options)):
				var dialogue_option = dialogue_options[i]
				dialogue_option.text = dialogue_dict[current_dialogue_id]["options"][i]["text"]
				dialogue_option.visible = true

func move_dialogue(id: String):
	current_dialogue_id = id
	dialogue.text = dialogue_dict[current_dialogue_id]["text"]
	for i in range(len(dialogue_options)):
		var dialogue_option = dialogue_options[i]
		dialogue_option.text = dialogue_dict[current_dialogue_id]["options"][i]["text"]

func read_json(path: String):
	if !FileAccess.file_exists(path):
		print("File not found at: " + path)
	
	var file = FileAccess.open(path, FileAccess.READ)
	var text = file.get_as_text()
	file.close()

	return JSON.parse_string(text)
	
