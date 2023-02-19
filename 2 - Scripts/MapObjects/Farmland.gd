extends Node2D
class_name Farmland

onready var sprite = $Sprite
var is_harvested = true

func _ready():
	$Clock.start(13)

func harvest():
	sprite.set_frame(0)
	is_harvested = true
	$Clock.start(13)
	Globals.game_world.ground._update_point_weight(get_global_position()/16, 1.0)

func regrow():
	sprite.set_frame(sprite.get_frame()+1)
	if sprite.get_frame() == 3:
		is_harvested = false
		return
	$Clock.start(13)
	Globals.game_world.ground._update_point_weight(get_global_position()/16, 10.0)
