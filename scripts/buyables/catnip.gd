extends Node

@onready var Player = get_tree().get_first_node_in_group("Player")

func do_the_thang() -> void:
	Player.SPEED *= 1.5
