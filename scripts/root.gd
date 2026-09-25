extends Control

@onready var soles: HBoxContainer = $UI/CanvasLayer/Control/HBoxContainer/VBoxContainer/Control/Soles
@onready var leave_point: Node2D = $World/LeavePoint

func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("add_soles"):
		soles.change_sole_count(soles.console_sole_count + 50)

func _ready() -> void:
	Global.leave_coords = leave_point.global_position

func passdown_change_soles(soles_to_add: int):
	soles.change_sole_count(soles.console_sole_count + soles_to_add)


func _on_leave_zone_body_entered(body: Node2D) -> void:
	body.queue_free()
