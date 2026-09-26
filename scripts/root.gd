extends Control

@onready var soles: HBoxContainer = $UI/CanvasLayer/Control/HBoxContainer/VBoxContainer/Control/Soles
@onready var leave_point: Node2D = $World/LeavePoint
@onready var banana_mation: AnimationPlayer = $UI/CanvasLayer/Control/HBoxContainer/VBoxContainer/Control/BananaLeafTutorial/BananaMation
@onready var movie_animation: AnimationPlayer = $UI/CanvasLayer/Control/MovieBars/MovieAnimation
@onready var thx_for_playing_node: Control = $UI/CanvasLayer/Control/ThxForPlaying

var tutorial_is_up = false

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("add_soles"):
		soles.change_sole_count(soles.console_sole_count + 50)
	if Input.is_action_just_pressed("action") and tutorial_is_up:
		banana_mation.play_backwards("tutorialup")
		tutorial_is_up = false

func _ready() -> void:
	Global.leave_coords = leave_point.global_position

func passdown_change_soles(soles_to_add: int) -> void:
	soles.change_sole_count(soles.console_sole_count + soles_to_add)

func check_if_you_can_buy(soles_needed: int) -> bool:
	if soles.check_sole_count(soles_needed):
		$UI/RegularerSoundFolder/Spendsoles.play()
		return true # now the buyable purchase goes through on it's end
	else:
		$UI/RegularerSoundFolder/Fartrejection.play()
		return false

func play_bananaleaf_tutorial() -> void:
	banana_mation.play("tutorialup")
	tutorial_is_up = true

func movie_bars_up() -> void:
	movie_animation.play("panels_in")

func thx_for_playing() -> void:
	var tween = create_tween()
	tween.tween_property(thx_for_playing_node, "modulate", Color(1, 1, 1, 1), 2)

func _on_leave_zone_body_entered(body: Node2D) -> void:
	body.queue_free()

func _on_lava_pool_body_entered(body: Node2D) -> void:
	body.in_lava.emit()

func _on_lava_pool_body_exited(body: Node2D) -> void:
	body.exit_lava.emit()
