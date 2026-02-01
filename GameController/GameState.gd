class_name GameState

var completed_npcs: Array[String] = [] # NPCs with exhausted dialogue
var story_flags: Array[String] = [] # storyline/progression flags

var susLevel : float
var maxSusLevel : float = 1

func complete_npc(npc_name: String) -> void:
	if npc_name not in completed_npcs:
		completed_npcs.append(npc_name)

func is_npc_completed(npc_name: String) -> bool:
	return npc_name in completed_npcs

func add_flag(flag: String) -> void:
	if flag not in story_flags:
		story_flags.append(flag)

func has_flag(flag: String) -> bool:
	return flag in story_flags

var current_disguise: String = "none"

func set_disguise(new_disguise: String):
	current_disguise = new_disguise
	if susLevel >= 0.1:
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
