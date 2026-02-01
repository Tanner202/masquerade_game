class_name UISystem

extends CanvasLayer

enum UIState {DEFAULT, NOTES}

# DEFAULT UI
@export var defaultUIHolder : Control
@export var susBar : TextureProgressBar
@export var susMoveDuration = 3.0
@export var susMoveBackDuration = 1.0
@export var interactText : Label
@export var changeToNotesUIButton : Button

# NOTES
@export var notesUIHolder : Control
@export var backToDefaultUIButton : Button


func _ready() -> void:
	setCanInteract(false)
	Controller.setUI(self)
	changeToNotesUIButton.pressed.connect(func(): setUI(UIState.NOTES))
	backToDefaultUIButton.pressed.connect(func(): setUI(UIState.DEFAULT))

func setUI(nextState : UIState) -> void:
	defaultUIHolder.hide()
	notesUIHolder.hide()
	if (nextState == UIState.DEFAULT):
		defaultUIHolder.show()
	elif (nextState == UIState.NOTES):
		notesUIHolder.show()

func setCanInteract(canInteract : bool):
	if (canInteract):
		interactText.show()
	else:
		interactText.hide()

func forceSetSusTo(value : float):
	susBar.value = value

func moveSusLevelToFun(newSusPercent : float):
		var passedVal = min(newSusPercent + 0.03, 1)
		if (passedVal != newSusPercent):
			await moveSusLevelTo(passedVal, susMoveDuration, false)
			await moveSusLevelTo(newSusPercent, susMoveBackDuration, true)
		else:
			await moveSusLevelTo(newSusPercent, susMoveDuration, true)

func moveSusLevelTo(newSusPercent : float, duration : float, slowAtEnd : bool) -> void:
	var curSus : float = susBar.value
	var timePassed : float = 0;
	while (timePassed < duration):
		var t : float = timePassed / duration
		if (slowAtEnd): 
			t = sqrt(t) 
		else: 
			t = t * t
		forceSetSusTo(Utils.lerp(curSus, newSusPercent, t))#susBar.anchor_right = Utils.lerp(curSus, newSusPercent, t)
		var prevTime : float = Time.get_ticks_msec()
		await get_tree().process_frame
		timePassed += (Time.get_ticks_msec() - prevTime) / 1000
	forceSetSusTo(newSusPercent)#susBar.anchor_right = newSusPercent
