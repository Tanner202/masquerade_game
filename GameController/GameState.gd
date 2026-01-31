class_name GameState

var susLevel : float
var maxSusLevel : float = 1

# constructor
func _init():
	susLevel = 0

func addToSus(amount : float) -> void:
	susLevel += amount
	
func gameIsOver():
	return susLevel >= maxSusLevel
