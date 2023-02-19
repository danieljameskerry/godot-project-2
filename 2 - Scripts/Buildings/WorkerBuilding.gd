extends Building
class_name WorkerBuilding

var current_workers = []
export var max_workers = 2
var yield_multiplier = 1
var item_ghost = preload("res://1 - Scenes/UI/ItemGhost.tscn")

func connect_signals():
	.connect_signals()
	Globals.game_world.connect("enter_assign_mode", self, "set_assign_highlight")
	Globals.game_world.connect("exit_assign_mode", self, "clear_assign_highlight")
	Globals.game_world.connect("enter_raid", self, "enter_raid")
	Globals.game_world.connect("exit_raid", self, "exit_raid")
	Globals.game_world.get_node("Camera2D").connect("zoom_level_changed", self, "adjust_prox_sound")
	adjust_prox_sound(Globals.game_world.get_node("Camera2D").zoom_level)

func upgrade():
	.upgrade()
	if level == 2 or level == 5:
		yield_multiplier *= 2
	elif level == 4:
		max_workers += 2

func process_next_behaviour(worker):
	worker.set_visible(false)

func get_assign_highlight() -> bool:
	if $Highlight.get_frame() > 1:
		return false
	return true

func set_assign_highlight(worker):
	if current_workers.has(worker):
		$Highlight.set_frame(2)
	elif current_workers.size() < max_workers:
		$Highlight.set_frame(1)
	else:
		$Highlight.set_frame(3)
	$Highlight.set_visible(true)

func clear_assign_highlight():
	$Highlight.set_visible(false)

func assign_worker(worker):
	current_workers.append(worker)

func unassign_worker(worker):
	current_workers.erase(worker)

func recieve_item(item: String):
	$AudioStreamPlayer2D.play()
	var new_item_ghost = item_ghost.instance()
	add_child(new_item_ghost)
	new_item_ghost.set_texture(Globals.resources[item].texture)
	Globals.resources[item].value += yield_multiplier
	Globals.game_world.user_interface.update_resource_counters()

func enter_raid():
	pass

func exit_raid():
	pass

func adjust_prox_sound(zoom_level: float):
	zoom_level = min(zoom_level, 1)
	$AudioStreamPlayer2D.set_max_distance(1000*zoom_level*1.25)
	zoom_level = 1 - min(zoom_level*2, 1)
	$AudioStreamPlayer2D.set_volume_db(linear2db(zoom_level))





