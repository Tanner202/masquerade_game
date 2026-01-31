class_name GameController

extends Node

var gameState : GameState = GameState.new()
const LOSE_SCENE_NAME = "res://Scenes/LoseScene.tscn"

func _init():
	pass

func raiseSus(amount : float) -> void:
	gameState.addToSus(amount)
	check_lose()

func check_lose() -> void:
	if (gameState.gameIsOver()):
		get_tree().change_scene(LOSE_SCENE_NAME)
