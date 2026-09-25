extends CharacterBody2D

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var hurtbox: Area2D = $AnimatedSprite2D/Hurtbox
@onready var hurtbox_collision: CollisionShape2D = $AnimatedSprite2D/Hurtbox/HurtboxCollision

const SPEED = 300.00
const JUMP_VELOCITY = -400.00
const ACCEL = 1
const DEACCEL = 75
const INV_ROOT_TWO = 0.707106781

enum STATES {
	IDLE,
	WALK,
	BANANALEAF, 
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

enum WEAPONS {
	BANANALEAF
}

var weapon : WEAPONS = WEAPONS.BANANALEAF

func _physics_process(_delta: float) -> void:
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_vector("left", "right", "up", "down")
	if direction:
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
		
		if not state == STATES.BANANALEAF:
			state = STATES.IDLE
		
	move_and_slide()

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("action") and not state == STATES.BANANALEAF:
		state = STATES.BANANALEAF
		
		# turn on hitbox
		hurtbox_collision.disabled = false
		


func _on_animated_sprite_2d_animation_finished() -> void:
	if state == STATES.BANANALEAF:
		hurtbox_collision.disabled = true
		state = STATES.IDLE # if not manually set, it will never leave BANANALEAF state
