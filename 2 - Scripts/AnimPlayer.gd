extends AnimationPlayer
class_name AnimPlayer

var anim_speed: float

func _ready():
	anim_speed = get_speed_scale()
	Globals.connect("speed_changed", self, "adjust_speed_scale")
	adjust_speed_scale()

func adjust_speed_scale():
	set_speed_scale(anim_speed * Globals.game_speed)
