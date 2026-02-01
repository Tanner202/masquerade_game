extends Control

@export var startButton : Button

func _ready():
	startButton.pressed.connect(func (): Controller.loadFirstScene())
