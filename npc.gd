class_name NPC extends Node

#@onready var dialogue = $Dialogue
@onready var interaction_prompt = $CanvasLayer/InteractionPrompt
#@export var dialogue_options: Array[Button]
const INTERACTION_SCENE = preload("res://interaction_scene.tscn")


var dialogue_filepath = "res://dialogue.json"
var dialogue_dict: Dictionary
var current_dialogue_id = "start"
var player_in_interaction_range = false
var player: CharacterBody2D = null
var is_interacting = false

func _ready() -> void:
	dialogue_dict = read_json(dialogue_filepath)
	#dialogue.text = dialogue_dict[current_dialogue_id]["text"]
	interaction_prompt.text = "Space to interact "
	interaction_prompt.visible = false

func _input(event: InputEvent) -> void:
	#if event.is_action_pressed("interact"):
		#if player_in_interaction_range:
			#if dialogue.visible == false:
				#dialogue.visible = true
				#interaction_prompt.visible = false
			#else:
				#for i in range(len(dialogue_options)):
					#var dialogue_option = dialogue_options[i]
					#dialogue_option.text = dialogue_dict[current_dialogue_id]["options"][i]["text"]
					#dialogue_option.visible = true
	if event.is_action_pressed("interact") and player_in_interaction_range and not is_interacting:
		start_interaction()

func start_interaction():
	is_interacting = true
	interaction_prompt.visible = false
	var interaction_instance = INTERACTION_SCENE.instantiate()
	
	get_tree().root.add_child(interaction_instance)
	interaction_instance.setup(dialogue_dict, current_dialogue_id, self)
	
	if player:
		player.can_move = false

func end_interaction():
	is_interacting = false
	if player_in_interaction_range:
		interaction_prompt.visible = true
	if player:
		player.can_move = true

#func move_dialogue(id: String):
	#current_dialogue_id = id
	#dialogue.visible = false
	#if player_in_interaction_range:
		#interaction_prompt.visible = true
	#dialogue.text = dialogue_dict[current_dialogue_id]["text"]
	#for dialogue_option in dialogue_options:
		#dialogue_option.visible = false

func read_json(path: String):
	if !FileAccess.file_exists(path):
		print("File not found at: " + path)
	
	var file = FileAccess.open(path, FileAccess.READ)
	var text = file.get_as_text()
	file.close()

	return JSON.parse_string(text)
	

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == 'Player':
		player_in_interaction_range = true
		player = body
		interaction_prompt.visible = true
		print('foo')

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.name == 'Player':
		player_in_interaction_range = false
		player = null
		interaction_prompt.visible = false
		print('bar')
