extends Timer
class_name Clock

var is_awaiting_start = false
var awaiting_start_time: float
var old_game_speed

func _ready():
	Globals.connect("speed_changed", self, "adjust_current_timer")
	old_game_speed = Globals.game_speed

func adjust_current_timer():
	if Globals.game_speed == 0:
		set_paused(true)
		return
	var was_paused = false
	if is_paused():
		was_paused = true
		set_paused(false)
	if not is_stopped():
		var time_adjust = {1: 0.5, 2: 2.0}
		if was_paused:
			time_adjust = {1: 1.0, 2: 2.0}
		.start(get_time_left() / time_adjust[Globals.game_speed])
	elif is_awaiting_start:
		is_awaiting_start = false
		.start(awaiting_start_time / Globals.game_speed as float)

func start(given_time: float = -1):
	if Globals.game_speed > 0:
		.start(given_time/Globals.game_speed as float)
		return
	is_awaiting_start = true
	awaiting_start_time = given_time
	
