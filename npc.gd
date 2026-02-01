class_name NPC extends CharacterBody2D

@export var npcID : String

# movement configs
@export var movement_speed: float = 60.0
@export var wander_radius: float = 300.0 # max roaming distance from start point
@export var min_idle_time: float = 2.0 # seconds
@export var max_idle_time: float = 5.0 # seconds

@export var sprite_frames: SpriteFrames

@export var required_flag: String = ""  # empty if npc has no requirement
var interaction_completed: bool = false

@export var portrait_texture: Texture2D

@onready var interaction_prompt = $CanvasLayer/InteractionPrompt
@onready var nav_agent = $NavigationAgent2D
@export_file("*.json") var dialogue_filepath: String
@onready var sprite = $AnimatedSprite2D
const INTERACTION_SCENE = preload("res://Scenes/interaction_scene.tscn")

# movement state stuff
enum State { IDLE, WANDER, FOLLOW, INTERACT, DEAD }
var current_state = State.IDLE
var start_position: Vector2
var idle_timer: float = 0.0
var follow_target: Node2D = null

var dialogue_dict: Dictionary
var current_dialogue_id = "start"
var player_in_interaction_range = false
var player: CharacterBody2D = null
var is_interacting = false
var just_started_wandering = false

var default_animation: String = "default"

func _ready() -> void:
	add_to_group("npcs")
	
	start_position = global_position
	
	nav_agent.path_desired_distance = 10.0
	nav_agent.target_desired_distance = 20.0
	
	if sprite_frames and sprite:
		sprite.sprite_frames = sprite_frames
		sprite.animation = default_animation
		sprite.play(default_animation)
		
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
	if can_interact():
		interaction_prompt.show() 
	else:
		interaction_prompt.hide()
	
	if is_interacting:
		current_state = State.INTERACT

	match current_state:
		State.IDLE:
			process_idle(delta)
			sprite.play("default")
		State.WANDER:
			process_movement(delta)
			sprite.play("walk")
		State.FOLLOW:
			process_follow(delta)
			sprite.play("walk")
		State.INTERACT:
			sprite.play("default")
			velocity = Vector2.ZERO # don't run away while mid interaciton
		State.DEAD:
			sprite.play("default")
			velocity = Vector2.ZERO # dead people don't move (hopefully)
			
#	if current_state != State.IDLE and current_state != State.INTERACT:
	move_and_slide()
	
func process_follow(delta):
	if not player:
		# no player, wander instead
		current_state = State.WANDER
		pick_new_wander_state()
		return
	
	var distance_to_player = global_position.distance_to(player.global_position)
	
	# don't get too close to player
	if distance_to_player < 50.0:
		velocity = Vector2.ZERO
		return
	
	var direction = global_position.direction_to(player.global_position)
	
	# only up down left right movement
	if abs(direction.x) > abs(direction.y):
		velocity = Vector2(sign(direction.x), 0) * movement_speed
	else:
		velocity = Vector2(0, sign(direction.y)) * movement_speed
	
	if velocity.x != 0:
		sprite.flip_h = velocity.x < 0
		
func process_idle(delta):
	velocity = Vector2.ZERO
	idle_timer -= delta
	if idle_timer <= 0:
		pick_new_wander_state()

func process_movement(delta):
	if just_started_wandering:
		just_started_wandering = false
		return
	
	if nav_agent.is_navigation_finished():
		# got to nav point, start idle
		current_state = State.IDLE
		idle_timer = randf_range(min_idle_time, max_idle_time)
		return
		
	# get destination
	var current_pos = global_position
	var next_path_pos = nav_agent.get_next_path_position()
	
	if current_pos.distance_to(nav_agent.target_position) < 10.0:
		current_state = State.IDLE
		idle_timer = randf_range(min_idle_time, max_idle_time)
		return
	
	var direction = current_pos.direction_to(next_path_pos)
	
	if abs(direction.x) > abs(direction.y):
		velocity = Vector2(sign(direction.x), 0) * movement_speed
	else:
		velocity = Vector2(0, sign(direction.y)) * movement_speed
	
	# flip npc sprite to face movement dir
	if velocity.x != 0:
		sprite.flip_h = velocity.x > 0

func pick_new_wander_state():
	current_state = State.WANDER
	just_started_wandering = true
	
	# send them off to a random point near the start spot
	var directions = [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]
	var random_dir = directions.pick_random()
	var random_dist = randf_range(50, wander_radius)
	var target_pos = start_position + (random_dir * random_dist)
	
	nav_agent.target_position = target_pos

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		if can_interact():
			start_interaction()

func start_following():
	current_state = State.FOLLOW
	
func stop_following():
	current_state = State.IDLE

func can_interact() -> bool:
	# can't interact if you are not in range or currently interacting
	if (not player_in_interaction_range or is_interacting):
		return false
	# make sure you are able to move in topdown mode first
	if not Controller.canInteract():
		return false
	# make sure npc hasn't alr been done
	if Controller.gameState.is_npc_completed(name):
		return false
	# make sure any requirements are met
	if required_flag != "" and not Controller.gameState.has_flag(required_flag):
		return false
	return true

func start_interaction():
	is_interacting = true
	interaction_prompt.visible = false
	current_state = State.INTERACT
	
	hide_all_characters()
	
	var interaction_instance = INTERACTION_SCENE.instantiate()
	
	Controller.setCurTalkingNPC(self)
	get_tree().root.add_child(interaction_instance)
	interaction_instance.setup(dialogue_dict, current_dialogue_id, self, portrait_texture)
	
	if player:
		player.can_move = false

func end_interaction(action_trigger: String = ""):
	is_interacting = false
	
	show_all_characters()
	
	match action_trigger:
		"follow":
			start_following()
		_:
			current_state = State.WANDER
			pick_new_wander_state()
	
	#if player_in_interaction_range and can_interact():
	#	interaction_prompt.visible = true
	if player:
		player.can_move = true

func hide_all_characters():
	# hide all npcs
	for npc in get_tree().get_nodes_in_group("npcs"):
		npc.visible = false
	# hide player
	if player:
		player.get_parent().visible = false

func show_all_characters():
	# show all npcs
	for npc in get_tree().get_nodes_in_group("npcs"):
		npc.visible = true
	# show player
	if player:
		player.get_parent().visible = true

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

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.name == 'Player':
		player_in_interaction_range = false
		if current_state != State.FOLLOW:
			player = null

func kill():
	if npcID == "PeacockLady":
		sprite.play("burn")
		await get_tree().create_timer(1).timeout
	if npcID == "BW":
		sprite.play("death")
		await get_tree().create_timer(1).timeout
		
	current_state = State.DEAD
	queue_free()
