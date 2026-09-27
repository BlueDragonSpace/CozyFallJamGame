extends Node

# worth noting that the bench uses code from the buyables, but has a cost of zero
@onready var behnch: Sprite2D = $"../Behnch"
@onready var Player = get_tree().get_first_node_in_group("Player")
@onready var bench: Area2D = $".."
@onready var bgm: AudioStreamPlayer = $"../../../BGM"

var tween2 : Tween
var tween3 : Tween

func _ready() -> void:
	Player.unsleep.connect(unsleeping)

func do_the_thang() -> void:
	var tween = create_tween()
	tween.tween_property(Player, "global_position", behnch.global_position, 0.3)
	Player.animated_sprite_2d.play("sleep")
	Player.sleeping = true
	Player.state = Player.STATES.SLEEP
	
	bench.invisibilize() # this is the parent, actually.. confusing, I know
	
	if tween3:
		tween3.kill()
	tween3 = create_tween()
	tween3.tween_property(bgm, "volume_db", -36, 5)
	
	if tween2:
		tween2.kill()
	tween2 = create_tween()
	tween2.tween_property(Player.main_cam, "zoom", Vector2(6, 6), 90)

func unsleeping() -> void:
	tween3.kill()
	tween2.kill()
