extends WorkerBuilding
class_name Mine

var yield_metal = false
var production_rate = 1

func upgrade():
	level += 1
	if level == 2 or level == 5:
		production_rate *= 2
	elif level == 3:
		max_workers += 2
	elif level == 4:
		yield_metal = true

func process_next_behaviour(worker: Worker):
	worker.set_visible(false)
	if worker.held_data == null:
		var clock = Clock.new()
		add_child(clock)
		worker.held_data = clock.name
		clock.start(10 / production_rate)
		yield(clock, "timeout")
		if worker.held_data == clock.name and Globals.is_in_raid == false:
			worker.held_data = null
			if yield_metal and randi() % 4 == 0:
				recieve_item("metal")
			else:
				recieve_item("stone")
		clock.queue_free()

func unassign_worker(worker):
	.unassign_worker(worker)
	worker.held_data = null

func enter_raid():
	for worker in current_workers:
		worker.held_data = null
