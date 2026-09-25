extends Node

var leave_coords := Vector2(0, 0)

func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("reset"):
		get_tree().reload_current_scene()
