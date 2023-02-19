extends Character
class_name Worker

onready var current_assigned_building: WorkerBuilding = get_parent()

func _ready():
	current_assigned_building.assign_worker(self)

func process_next_behaviour():
	if Globals.is_in_raid:
		set_visible(false)
		return
	current_assigned_building.process_next_behaviour(self)

func assign(building: WorkerBuilding):
	drop_resource()
	current_assigned_building.unassign_worker(self)
	current_assigned_building = building
	current_assigned_building.assign_worker(self)
	set_destination(current_assigned_building.get_global_position())

func pickup_resource(resource: String):
	var item_frames = {"food": 0, "wood": 1, "stone": 2, "metal": 3}
	$CarriedItem.set_frame(item_frames[resource])
	$CarriedItem.set_visible(true)
	current_state = "Carry"

func drop_resource():
	$CarriedItem.set_visible(false)
	current_state = "Walk"

func enter_raid_mode():
	drop_resource()
	speed *= 2.0
	if current_assigned_building != get_parent():
		set_destination(get_parent().get_global_position())

func exit_raid_mode():
	speed /= 2.0
	if current_assigned_building != get_parent():
		set_destination(current_assigned_building.get_global_position())
