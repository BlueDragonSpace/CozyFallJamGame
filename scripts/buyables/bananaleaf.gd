extends Node

@onready var Player = get_tree().get_first_node_in_group("Player")
@onready var Root = get_tree().get_first_node_in_group("Root")

func do_the_thang() -> void:
	Player.has_bananaleaf = true
	Root.play_bananaleaf_tutorial()
