extends Tween
class_name Tween2

func _ready():
	Globals.connect("speed_changed", self, "adjust_speed_scale")
	set_speed_scale(Globals.game_speed)

func adjust_speed_scale():
	set_speed_scale(Globals.game_speed)
