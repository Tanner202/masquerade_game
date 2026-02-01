extends Node2D

var player_in_interaction_range = false
var player: CharacterBody2D = null
@export var room_path: String
@export var target_door: String
@onready var interaction_prompt = $CanvasLayer/InteractionPrompt

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == 'Player':
		player_in_interaction_range = true
		player = body
		interaction_prompt.visible = true

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.name == 'Player':
		player_in_interaction_range = false
		player = null
		interaction_prompt.visible = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and player_in_interaction_range:
		TransitionManager.set_target_door(target_door)
		TransitionManager.change_scene(room_path)
