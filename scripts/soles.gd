extends HBoxContainer

@onready var label: Label = $Label
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var console_sole_count : int = 0 # equivalent to sole count, but is invisible to player, the other is on the UI
var sole_count : int = 0:
	set(new):
		sole_count = clamp(new, 0, INF)
		label.text = str(sole_count)
		rotation = randf_range(-PI/16, PI/16)

var got_first_sole = false

func change_sole_count(new_sole_count: int) -> void:
	console_sole_count = new_sole_count
	
	if not got_first_sole:
		animation_player.play("first_time_in")
		got_first_sole = true
	
	var tween = create_tween()
	tween.tween_property(self, "sole_count", console_sole_count, 0.5)
