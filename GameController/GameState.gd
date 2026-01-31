class_name GameState

var susLevel : float
var maxSusLevel : float = 1

var current_disguise: String = "none"

func set_disguise(new_disguise: String):
	current_disguise = new_disguise
	susLevel -= 0.1 # optional having changing disguises decrease suspicion
	
# constructor
func _init():
	susLevel = 0

func addToSus(amount : float) -> void:
	susLevel += amount
	susLevel = min(susLevel, maxSusLevel)

func percentSus() -> float:
	return susLevel / maxSusLevel
	
func gameIsOver():
	return susLevel >= maxSusLevel
