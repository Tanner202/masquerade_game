class_name GameController

extends Node

var ui : UISystem;
var gameState : GameState = GameState.new()
const LOSE_SCENE_NAME = "res://LoseScene.tscn"

func _init():
	pass

func setUI(newUI : UISystem):
	ui = newUI
	ui.setUI(UISystem.UIState.DEFAULT)

func raiseSus(amount : float) -> void:
	if (gameState.gameIsOver()):
		return #ignore if the game is currently over
	gameState.addToSus(amount)
	await ui.moveSusLevelToFun(gameState.percentSus())
	check_lose()

func check_lose() -> void:
	if (gameState.gameIsOver()):
		get_tree().change_scene_to_file(LOSE_SCENE_NAME)
