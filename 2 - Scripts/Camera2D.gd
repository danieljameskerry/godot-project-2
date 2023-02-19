extends Camera2D

export var min_zoom := 0.1
export var max_zoom := 1.6
export var zoom_factor := 1.1
export var zoom_duration := 0.2
var zoom_level := 1.6
onready var tween: Tween = $Tween

var velocity = Vector2.ZERO
export var max_speed = 8
const acceleration = 30

var mouse_start_pos
var screen_start_position
var dragging = false   

signal zoom_level_changed

func set_zoom_level(value: float) -> void:
	zoom_level = clamp(value, min_zoom, max_zoom)
	emit_signal("zoom_level_changed", zoom_level)
# warning-ignore:return_value_discarded
	tween.interpolate_property(self,"zoom",zoom,Vector2(zoom_level, zoom_level),
	zoom_duration,tween.TRANS_SINE,tween.EASE_OUT)
# warning-ignore:return_value_discarded
	tween.start()

func _unhandled_input(event):
	if Input.is_mouse_button_pressed(5):
		set_zoom_level(zoom_level * zoom_factor)
	elif Input.is_mouse_button_pressed(4):
		set_zoom_level(zoom_level / zoom_factor)

	if event.is_action("drag"):
		if event.is_pressed():
			mouse_start_pos = event.position
			screen_start_position = position
			dragging = true
		else:
			dragging = false
		get_tree().set_input_as_handled()
	elif event is InputEventMouseMotion and dragging:
		position = zoom * (mouse_start_pos - event.position) + screen_start_position
		get_tree().set_input_as_handled()

func _process(delta):
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	input_vector.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	input_vector = input_vector.normalized()
	velocity = velocity.move_toward(input_vector * max_speed, acceleration * delta)
	set_position(position+velocity*zoom)
