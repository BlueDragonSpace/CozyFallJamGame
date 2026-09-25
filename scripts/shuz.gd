extends CharacterBody2D

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var animation_player: AnimationPlayer = $AnimationTree/AnimationPlayer
@onready var sight_radius: Area2D = $SightRadius
@onready var navigation_agent: NavigationAgent2D = get_node("NavigationAgent2D")
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var soles_particles: GPUParticles2D = $SolesParticles
@onready var relax_dialogue: Label = $AnimatedSprite2D2/RelaxDialogue

var SPEED = 200.00 ## whoops i don't wanna lowercase this
const JUMP_VELOCITY = -400.00
const ACCEL = 1
const DEACCEL = 750
const INV_ROOT_TWO = 0.707106781

var dialogues = ['Wow! I feel so relaxed! Thanks!!!', 'Huh. That wasn\'t so bad!', 'This is quite nice!', '10/10. Would come again.', 'I love this place!', 'I\'m going to write a poem!', 'This is fire.', 'YOLO', 'mmmmmm burnt rubber', 'Thank you, Demonkat!', 'blehhhhhhh']

signal shuz_soles(new_soles: int)

enum STATES {
	IDLE,
	WALK,
	DAMAGED
}
@onready var state : STATES = STATES.IDLE:
	set(new):
		state = new
		
		if not state == STATES.DAMAGED:
			var tween = create_tween()
			match(new):
				STATES.IDLE: 
					tween.tween_property(animation_tree, "parameters/blend_position", -1, 0.5)
				STATES.WALK:
					tween.tween_property(animation_tree, "parameters/blend_position", 1, 0.5)
		else:
			animated_sprite_2d.play("damaged")
		

var running_from : Node
var is_running := false
var hp = 2 # there is the possibility that one shoe type might have more hp, and not be damaged upon having 1 less hp
var damaged = false
var leaving = false # once they've gone through the full relaxation phase

func _physics_process(_delta: float) -> void:
	#var direction := Input.get_vector("left", "right", "up", "down")
	
	var direction : Vector2
	
	if is_running and not leaving and not hp == 0:
		var angle = running_from.get_angle_to(self.global_position)
		direction.x = cos(angle) # + PI/2 orbits
		# + PI goes toward player
		direction.y = sin(angle)
		
		set_movement_target(self.global_position + direction * 200) # move away from player in relation to pathfinding
		
		
		# Do not query when the map has never synchronized and is empty.
		if NavigationServer2D.map_get_iteration_id(navigation_agent.get_navigation_map()) == 0:
			return
		if navigation_agent.is_navigation_finished():
			return
		
		state = STATES.WALK
	elif leaving:
		set_movement_target(Global.leave_coords)
	else:
		velocity.x = move_toward(velocity.x, 0, DEACCEL * INV_ROOT_TWO)
		velocity.y = move_toward(velocity.y, 0, DEACCEL * INV_ROOT_TWO)
		state = STATES.IDLE
		
	move_and_slide()

func _on_sight_radius_body_entered(body: Node2D) -> void:
	is_running = true
	running_from = body

func _on_sight_radius_body_exited(_body: Node2D) -> void:
	is_running = false

func _ready() -> void:
	navigation_agent.velocity_computed.connect(Callable(_on_velocity_computed))
	shuz_soles.connect(get_tree().get_first_node_in_group("Root").passdown_change_soles)
	
	# sets the dialogue to be a random dialogue from the list
	relax_dialogue = dialogues[randi_range(0, dialogues.size() - 1)]

func set_movement_target(movement_target: Vector2):
	navigation_agent.set_target_position(movement_target)

	var next_path_position: Vector2 = navigation_agent.get_next_path_position()
	var new_velocity: Vector2 = global_position.direction_to(next_path_position) * 100
	if navigation_agent.avoidance_enabled:
		navigation_agent.set_velocity(new_velocity)
	else:
		_on_velocity_computed(new_velocity)

func _on_velocity_computed(safe_velocity: Vector2):
	
	if not hp == 0 or leaving:
		velocity = safe_velocity
		move_and_slide()

func get_hit():
	hp -= 1
	hp = max(hp, 0) # makes sure hp never goes below 0
	damaged = true
	
	if not leaving:
		if hp == 0:
			relax()
		else:
			state = STATES.DAMAGED

func relax():
	animation_tree.active = false
	animation_player.play("relax")
	animated_sprite_2d.play('relaxed')

func _on_hitbox_area_entered(_area: Area2D) -> void:
	get_hit()

func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	if hp == 0 and not leaving:
		animated_sprite_2d.play('gleeful')
		soles_particles.emitting = true
		shuz_soles.emit(randi_range(8, 15))
		leaving = true
		SPEED /= 2
