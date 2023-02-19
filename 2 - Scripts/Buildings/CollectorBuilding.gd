extends WorkerBuilding
class_name CollectorBuilding

var claimed_objects = Globals.worker_claimed_objects
export var operating_radius = 2
onready var radius = $Radius
var current_harvesting_workers: Array = []

export var target_object_id: String = "tree"
export var resource_collected: String = "wood"

func upgrade():
	.upgrade()
	if level == 3:
		operating_radius += 2

func process_next_behaviour(worker: Worker):
	if worker.target_position == get_global_position():
		worker.set_visible(false)
		if worker.current_state == "Carry":
			recieve_item(resource_collected)
			worker.drop_resource()
		var nearest_object = find_nearest_object()
		if nearest_object != null:
			worker.current_path = Globals.game_world.evaluate_path(worker.target_position, nearest_object.get_global_position())
			worker.current_destination = worker.current_path[-1] * 16
			worker.held_data = nearest_object.get_global_position()
			claimed_objects[worker.held_data / 16] = nearest_object
	
	elif not current_harvesting_workers.has(worker) and not worker.is_moving:
		current_harvesting_workers.append(worker)
		var direction = worker.animPlayer.get_current_animation().substr(4)
		worker.animPlayer.play("Swipe"+direction)
		worker.get_node("Sprite").set_position(Vector2(8,8) - (4 * worker.directions[direction]))
		var clock = Clock.new()
		add_child(clock)
		clock.start(9)
		current_harvesting_workers.append(clock.name)
		yield(clock, "timeout")
		if current_harvesting_workers.has(clock.name):
			worker.get_node("Sprite").set_position(Vector2(8,8))
			if Globals.is_in_raid == false:
				claimed_objects[worker.held_data / 16].harvest()
				worker.pickup_resource(resource_collected)
				worker.set_destination(get_global_position())
			claimed_objects.erase(worker.held_data / 16)
			worker.held_data = null
			current_harvesting_workers.erase(worker)
			current_harvesting_workers.erase(clock.name)
		clock.queue_free()

func find_nearest_object() -> Node2D:
	var closest_object = null
	var closest_distance = 100.0
	for x in (2 * operating_radius + 1):
		for y in (2 * operating_radius + 1):
			var coords = get_global_position()/16 + Vector2(x-operating_radius,y-operating_radius)
			if Globals.object_grid.get(coords, {"id": "-"}).id == target_object_id:
				var next_object: Node2D = Globals.object_grid[coords].instance
				if not next_object.is_harvested and not claimed_objects.get(coords):
					var distance = ((get_global_position() - next_object.get_global_position())/16).length_squared()
					if distance < closest_distance:
						closest_object = next_object
						closest_distance = distance
	return closest_object

func unassign_worker(worker):
	.unassign_worker(worker)
	if current_harvesting_workers.has(worker):
		worker.get_node("Sprite").set_position(Vector2(8,8))
		current_harvesting_workers.remove(current_harvesting_workers.find(worker) + 1)
		current_harvesting_workers.erase(worker)
	if worker.held_data != null:
		claimed_objects.erase(worker.held_data / 16)
		worker.held_data = null

func enter_raid():
	for worker in current_workers:
		if current_harvesting_workers.has(worker):
			worker.get_node("Sprite").set_position(Vector2(8,8))
			current_harvesting_workers.remove(current_harvesting_workers.find(worker) + 1)
			current_harvesting_workers.erase(worker)
		if worker.held_data != null:
			claimed_objects.erase(worker.held_data / 16)
			worker.held_data = null
