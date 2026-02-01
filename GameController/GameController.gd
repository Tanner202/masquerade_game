class_name GameController

extends Node

var ui : UISystem;
var gameState : GameState = GameState.new()
const LOSE_SCENE_NAME = "res://LoseScene.tscn"
const FIRST_SCENE = "res://Scenes/level.tscn"
var interactables : Array[NPC] = []

func _init():
	pass

func setUI(newUI : UISystem):
	ui = newUI
	ui.forceSetSusTo(gameState.percentSus())
	ui.setUI(UISystem.UIState.DEFAULT)

func addAsInteractable(interactable : NPC):
	if interactables.find(interactable) != -1:
		return
	interactables.push_front(interactable)
	setCanTalk(interactables.size() > 0)
	
func removeAsInteractable(interactable : NPC):
	var indexOfInteractable = interactables.find(interactable)
	if (indexOfInteractable != -1):
		interactables.remove_at(indexOfInteractable)
	setCanTalk(interactables.size() > 0)

func setCanTalk(canTalk : bool):
	ui.setCanInteract(canTalk)

func raiseSus(amount : float) -> void:
	if (gameState.gameIsOver()):
		return #ignore if the game is currently over
	gameState.addToSus(amount)
	await ui.moveSusLevelToFun(gameState.percentSus())
	check_lose()

func check_lose() -> void:
	if (gameState.gameIsOver()):
		loadScene(LOSE_SCENE_NAME)

func loadScene(sceneName : String) -> void:
	get_tree().change_scene_to_file(sceneName)

func loadFirstScene() -> void:
	loadScene(FIRST_SCENE)
