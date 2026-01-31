extends Control

enum UIState {DEFAULT, NOTES}

@export var defaultUIHolder : Control
@export var notesUIHolder : Control

func _ready() -> void:
	setUI(UIState.NOTES)
	Controller.raiseSus(1)

func setUI(nextState : UIState) -> void:
	defaultUIHolder.hide()
	notesUIHolder.hide()
	if (nextState == UIState.DEFAULT):
		defaultUIHolder.show()
	elif (nextState == UIState.NOTES):
		notesUIHolder.show()
