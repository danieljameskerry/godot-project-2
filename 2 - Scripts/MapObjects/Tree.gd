extends MapObject

var original_frame: int
var is_harvested = false

func _ready():
	original_frame = sprite.get_frame()

func harvest():
	sprite.set_frame(0)
	is_harvested = true
	$Clock.start(40)
	Globals.game_world.ground._update_point_weight(get_global_position()/16, 1.0)

func regrow():
	sprite.set_frame(original_frame)
	is_harvested = false
	Globals.game_world.ground._update_point_weight(get_global_position()/16, 10.0)
