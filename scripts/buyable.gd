extends Area2D

# lol time for copypasting cuz this is a game jam

@onready var Root = get_tree().get_first_node_in_group("Root")
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var additional_script: Node = $AdditionalScript


@onready var Name: Label = $Panel/VBoxContainer/Name
@onready var Cost: Label = $Panel/VBoxContainer/Cost

@export var cost : int = 100
@export var item_name : String = "Catnip"

func _ready() -> void:
	Name.text = item_name
	Cost.text = str(cost)

func visibilize() -> void:
	animation_player.play("visibilize")

func invisibilize() -> void:
	animation_player.play_backwards("visibilize")

func buy() -> void:
	if Root.check_if_you_can_buy(cost):
		additional_script.do_the_thang()
		queue_free()
