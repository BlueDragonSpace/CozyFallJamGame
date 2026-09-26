extends VisibleOnScreenNotifier2D


@onready var children_holder: Node2D = $ChildrenHolder
@onready var timer: Timer = $Timer
@export var max_children : int = 3
@export var timer_time := 10.5

const SHUZ = preload("uid://ybcq4eyw85gw")

func _ready() -> void:
	timer.wait_time = timer_time

func _on_timer_timeout() -> void:
	
	if children_holder.get_child_count() < max_children:
		var child = SHUZ.instantiate()
		# in reference to the spawner's bounding box
		@warning_ignore("narrowing_conversion")
		child.position.x += randi_range(rect.size.x/2.0 - 16, -rect.size.x/2.0 + 16)
		@warning_ignore("narrowing_conversion")
		child.position.y += randi_range(rect.size.y/2.0 - 16, -rect.size.y/2.0 + 16)
		children_holder.add_child(child)

# funny enough, I need the exact opposite of an on-screen enabler
# this disables while on screen
func _on_screen_entered() -> void:
	timer.process_mode = Node.PROCESS_MODE_DISABLED

func _on_screen_exited() -> void:
	timer.process_mode = Node.PROCESS_MODE_INHERIT
