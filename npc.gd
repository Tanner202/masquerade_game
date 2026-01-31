class_name NPC extends CharacterBody2D

# movement configs
@export var movement_speed: float = 60.0
@export var wander_radius: float = 300.0 # max roaming distance from start point
@export var min_idle_time: float = 2.0 # seconds
@export var max_idle_time: float = 5.0 # seconds

@onready var interaction_prompt = $CanvasLayer/InteractionPrompt
@onready var nav_agent = $NavigationAgent2D
@export_file("*.json") var dialogue_filepath: String
@onready var sprite = $Sprite2D
@export var npc_texture: Texture2D
const INTERACTION_SCENE = preload("res://interaction_scene.tscn")

# movement state stuff
enum State { IDLE, WANDER, FOLLOW, INTERACT }
var current_state = State.IDLE
var start_position: Vector2
var idle_timer: float = 0.0
var follow_target: Node2D = null

var dialogue_dict: Dictionary
var current_dialogue_id = "start"
var player_in_interaction_range = false
var player: CharacterBody2D = null
var is_interacting = false

func _ready() -> void:
	start_position = global_position
	
	nav_agent.path_desired_distance = 10.0
	nav_agent.target_desired_distance = 20.0
	
	if npc_texture and sprite:
		sprite.texture = npc_texture
		
	if dialogue_filepath == "":
		printerr("No dialogue json file for: " + name)
		return
	
	dialogue_dict = read_json(dialogue_filepath)
	#dialogue.text = dialogue_dict[current_dialogue_id]["text"]
	interaction_prompt.text = "Space to interact "
	interaction_prompt.visible = false
	
	call_deferred("movement_setup")
	
func movement_setup():
	await get_tree().physics_frame
	pick_new_wander_state()

func _physics_process(delta):
	if is_interacting:
		current_state = State.INTERACT

	match current_state:
		State.IDLE:
			process_idle(delta)
		State.WANDER:
			process_movement(delta)
		State.FOLLOW:
			pass
		State.INTERACT:
			velocity = Vector2.ZERO # don't run away while mid interaciton
			
#	if current_state != State.IDLE and current_state != State.INTERACT:
	move_and_slide()
		
func process_idle(delta):
	velocity = Vector2.ZERO
	idle_timer -= delta
	if idle_timer <= 0:
		pick_new_wander_state()

func process_movement(delta):
	if nav_agent.is_navigation_finished():
		print("Navigation finished - going idle")
		# got to nav point, start idle
		current_state = State.IDLE
		idle_timer = randf_range(min_idle_time, max_idle_time)
		return
		
	# get destination
	var current_pos = global_position
	var next_path_pos = nav_agent.get_next_path_position()
	print("Moving toward: ", next_path_pos)
	velocity = current_pos.direction_to(next_path_pos) * movement_speed
	
	# flip npc sprite to face movement dir
	if velocity.x != 0:
		sprite.flip_h = velocity.x < 0

func pick_new_wander_state():
	current_state = State.WANDER
	
	# send them off to a random point near the start spot
	var random_dir = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
	var random_dist = randf_range(50, wander_radius)
	var target_pos = start_position + (random_dir * random_dist)
	
	nav_agent.target_position = target_pos

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and player_in_interaction_range and not is_interacting:
		start_interaction()

func start_interaction():
	is_interacting = true
	interaction_prompt.visible = false
	current_state = State.INTERACT
	
	var interaction_instance = INTERACTION_SCENE.instantiate()
	
	get_tree().root.add_child(interaction_instance)
	interaction_instance.setup(dialogue_dict, current_dialogue_id, self)
	
	if player:
		player.can_move = false

func end_interaction():
	is_interacting = false
	if current_state != State.FOLLOW:
		current_state = State.WANDER
	pick_new_wander_state()
	
	if player_in_interaction_range:
		interaction_prompt.visible = true
	if player:
		player.can_move = true

#func move_dialogue(id: String):
	#current_dialogue_id = id
	#dialogue.visible = false
	#if player_in_interaction_range:
		#interaction_prompt.visible = true
	#dialogue.text = dialogue_dict[current_dialogue_id]["text"]
	#for dialogue_option in dialogue_options:
		#dialogue_option.visible = false

func read_json(path: String):
	if !FileAccess.file_exists(path):
		print("File not found at: " + path)
	
	var file = FileAccess.open(path, FileAccess.READ)
	var text = file.get_as_text()
	file.close()

	return JSON.parse_string(text)
	

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == 'Player':
		player_in_interaction_range = true
		player = body
		interaction_prompt.visible = true

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.name == 'Player':
		player_in_interaction_range = false
		player = null
		interaction_prompt.visible = false
