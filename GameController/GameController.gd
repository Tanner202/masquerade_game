class_name GameController

extends Node

var seenIntroScroll = false
var player : Player
var trigger_kill : bool
var ui : UISystem;
var curInteraction
var curNPC : NPC
var gameState : GameState = GameState.new()
const LOSE_SCENE_NAME = "res://Scenes/LoseScene.tscn"
const FIRST_SCENE_NAME = "res://Scenes/level.tscn"

func _init():
	pass

func setCurTalkingNPC(npc : NPC):
	curNPC = npc

func setInteraction(i):
	curInteraction = i

func setPlayer(givenPlayer : Player):
	player = givenPlayer
	player.can_move = false
	
	# Quick check to make sure UI is set before finishing setting player
	while (ui == null):
		await get_tree().process_frame
	
	if (not seenIntroScroll):
		seenIntroScroll = true
		ui.setUI(UISystem.UIState.INTRO_SCROLL)
		ui.setExitIntroButton(
			func (): 
				player.can_move = true
				ui.setUI(UISystem.UIState.DEFAULT)
		)
	else:
		player.can_move = true
	
	# Setup Death Trigger
	if (not gameState.has_flag("bw_killed")):
		tryKillBW()
	if (not gameState.has_flag("pl_killed")):
		tryKillPL()

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
		for child in get_tree().root.get_children():
			if child.name == "InteractionScreen":
				child.queue_free()
		loadScene(LOSE_SCENE_NAME)

func canInteract():
	return player != null and player.can_move

func loadScene(sceneName : String):
	get_tree().change_scene_to_file(sceneName)

func loadFirstScene():
	loadScene(FIRST_SCENE_NAME)

func tryKillBW():
	# Wait until you are trying to kill BW
	while (not gameState.has_flag("bw_killed") or curInteraction != null):
		await get_tree().process_frame
	
	curNPC.kill()
	player.can_move = false
	print("Pre stab")
	await player.playStab()
	print("After stab")
	await player.setSpriteToFun(Player.Char.BW)
	print("After setSpriteToFun")
	player.can_move = true
	
func tryKillPL():
	# Wait until you are trying to kill BW
	while (not gameState.has_flag("pl_killed") or curInteraction != null):
		await get_tree().process_frame
	
	curNPC.kill()
	player.can_move = false
	await player.setSpriteToFun(Player.Char.PL)
	player.can_move = true
