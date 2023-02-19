extends WorkerBuilding
class_name Hut

func set_assign_highlight(worker):
	if current_workers.has(worker):
		$Highlight.set_frame(2)
	elif worker == $Worker:
		$Highlight.set_frame(1)
	else:
		$Highlight.set_frame(3)
		return
	$Highlight.set_visible(true)

func enter_raid():
	$Worker.enter_raid_mode()

func exit_raid():
	$Worker.exit_raid_mode()

func adjust_prox_sound(zoom_level: float):
	zoom_level = min(zoom_level, 0.8)*1.25
	$AudioStreamPlayer2D.set_max_distance(1000*zoom_level*1.25)
	$Worker.get_node("AudioStreamPlayer2D").set_max_distance(1000*zoom_level*1.25)
	zoom_level = 1 - min(zoom_level*2, 1)
	$AudioStreamPlayer2D.set_volume_db(linear2db(zoom_level))
	$Worker.get_node("AudioStreamPlayer2D").set_volume_db(linear2db(zoom_level))
