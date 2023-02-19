extends Node2D
class_name Character

export var speed = 2.0
var current_state = "Walk"
var directions = {"Up": Vector2.UP, "Down": Vector2.DOWN, "Left": Vector2.LEFT, "Right": Vector2.RIGHT}
var is_moving = false
onready var target_position: Vector2 = get_global_position()

var current_path: PoolVector2Array = []
onready var current_destination: Vector2 = get_global_position()

onready var animPlayer = $AnimationPlayer
onready var tween = $Tween

var held_data = null

func _process(_delta):
	if target_position == current_destination:
		process_next_behaviour()
	elif not is_moving:
		set_visible(true)
		for direction in directions.keys():
			if (current_path[0] - get_global_position()/16) == directions[direction]:
				current_path.remove(0)
				move(direction)
				return

func process_next_behaviour():
	pass

func move(direction: String):
	is_moving = true
	animPlayer.play(current_state+direction)
	target_position = get_global_position() + (directions[direction] * 16)
	tween.interpolate_property(self, "global_position", get_global_position(), target_position, 1/(speed as float), Tween.TRANS_LINEAR)
	tween.start()
	yield(tween, "tween_completed")
	is_moving = false

func set_destination(destination: Vector2):
	current_path = Globals.game_world.evaluate_path(target_position, destination)
	current_destination = current_path[-1] * 16
