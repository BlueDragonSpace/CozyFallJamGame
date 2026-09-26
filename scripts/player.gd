extends CharacterBody2D

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var hurtbox: Area2D = $AnimatedSprite2D/Hurtbox
@onready var hurtbox_collision: CollisionShape2D = $AnimatedSprite2D/Hurtbox/HurtboxCollision
@onready var on_fire: AnimatedSprite2D = $OnFire
@onready var heaven_cam: Camera2D = $HeavenLight/Node/HeavenCam
@onready var heaven_animation: AnimationPlayer = $HeavenLight/HeavenAnimation
@onready var main_cam: Camera2D = $MainCam
@onready var meow_box: Area2D = $MeowBox


var SPEED = 175.00 # oh no, i named a constant in all capitals
const JUMP_VELOCITY = -400.00
const ACCEL = 1
const DEACCEL = 75
const INV_ROOT_TWO = 0.707106781

signal in_lava
signal exit_lava

enum STATES {
	IDLE,
	WALK,
	BANANALEAF,
	MEOW,
}

# now that I think of it these are only visual states...
@onready var state : STATES = STATES.IDLE:
	set(new):
		state = new
		var tween = create_tween()
		
		match(new):
			STATES.IDLE: 
				tween.tween_property(animation_tree, "parameters/blend_position", -1, 0.5)
				animated_sprite_2d.play("idle")
			STATES.WALK:
				tween.tween_property(animation_tree, "parameters/blend_position", 1, 0.5)
				animated_sprite_2d.play('walk')
			STATES.BANANALEAF:
				tween.tween_property(animation_tree, "parameters/blend_position", -1, 0.5)
				animated_sprite_2d.play("bananaleaf")
			STATES.MEOW:
				tween.tween_property(animation_tree, "parameters/blend_position", -1, 0.5)
				animated_sprite_2d.play("meow")

enum WEAPONS {
	BANANALEAF
}

var weapon : WEAPONS = WEAPONS.BANANALEAF
var meowing = false
var has_bananaleaf = false
var in_control = true

func _physics_process(_delta: float) -> void:
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	if in_control:
		var direction := Input.get_vector("left", "right", "up", "down")
		if direction:
			if not $RegularSoundFolder/Catstep.playing:
				$RegularSoundFolder/Catstep.pitch_scale = randf_range(0.9, 1.1)
				$RegularSoundFolder/Catstep.play()
			velocity = velocity.lerp(direction * SPEED, ACCEL)
			if not state == STATES.BANANALEAF:
				state = STATES.WALK
			if velocity.x < 0:
				animated_sprite_2d.flip_h = true
				hurtbox.scale.x = -1
			elif velocity.x > 0:
				animated_sprite_2d.flip_h = false
				hurtbox.scale.x = 1
		else:
			velocity.x = move_toward(velocity.x, 0, DEACCEL * INV_ROOT_TWO)
			velocity.y = move_toward(velocity.y, 0, DEACCEL * INV_ROOT_TWO)
			
			if not state == STATES.BANANALEAF and not state == STATES.MEOW:
				state = STATES.IDLE
			
		move_and_slide()

func _ready() -> void:
	in_lava.connect(fall_in_lava)
	exit_lava.connect(exit_lava_function)

func _input(_event: InputEvent) -> void:
	if in_control:
		if Input.is_action_just_pressed("action") and not state == STATES.BANANALEAF and has_bananaleaf:
			state = STATES.BANANALEAF
			
			# turn on hitbox
			hurtbox_collision.disabled = false
			$RegularSoundFolder/Bananaleafwhiff.play()
		elif Input.is_action_just_pressed("meow") and not state == STATES.BANANALEAF:
			state = STATES.MEOW
			animated_sprite_2d.play("meow")
			meowing = true
			$RegularSoundFolder/MarioMeow.play()
			if meow_box.has_overlapping_areas():
				var buything = meow_box.get_overlapping_areas()
				buything[0].buy() # if somehow there are multiple, it just does one

func fall_in_lava():
	SPEED *= 2
	on_fire.visible = true
	$RegularSoundFolder/Onfire.playing = true

func exit_lava_function():
	SPEED /= 2
	on_fire.visible = false
	$RegularSoundFolder/Onfire.playing = false

func ascend():
	heaven_animation.play("ascend")
	heaven_cam.position = main_cam.global_position
	heaven_cam.zoom = main_cam.zoom
	in_control = false

func _on_animated_sprite_2d_animation_finished() -> void:
	if state == STATES.BANANALEAF or state == STATES.MEOW:
		hurtbox_collision.disabled = true
		state = STATES.IDLE # if not manually set, it will never leave BANANALEAF state
		meowing = false


func _on_meow_box_area_entered(area: Area2D) -> void:
	area.visibilize()

func _on_meow_box_area_exited(area: Area2D) -> void:
	area.invisibilize()
