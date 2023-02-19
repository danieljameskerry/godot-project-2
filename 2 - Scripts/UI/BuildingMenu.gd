extends Control
class_name BuildingMenu

onready var title = $VBoxContainer/TextContent/Title
onready var level = $VBoxContainer/TextContent/Level
onready var description = $VBoxContainer/TextContent/Description
onready var assignment = $VBoxContainer/TextContent/Assignment
onready var buttons = $VBoxContainer/Buttons
onready var repairButton = $VBoxContainer/Buttons/RepairButton
onready var upgradeButton = $VBoxContainer/Buttons/UpgradeButton
onready var worker_buttons = $VBoxContainer/Buttons/WorkerButtons

onready var upgrade_hbox = $VBoxContainer/Buttons/UpgradeButton/HBox
onready var upgrade_counter = preload("res://1 - Scenes/UI/PlacingCounter.tscn")
onready var upgrade_counters = {}

onready var repair_hbox = $VBoxContainer/Buttons/RepairButton/HBox
onready var repair_counters = {}

func connect_signals():
	load_resources()
	repairButton.connect("pressed", Globals.game_world, "repair_keep")
	upgradeButton.connect("pressed", Globals.game_world, "upgrade_building")
	worker_buttons.get_node("GotoButton").connect("pressed", Globals.game_world, "goto_worker")
	worker_buttons.get_node("AssignButton").connect("pressed", Globals.game_world, "enter_assign_mode")
	Globals.game_world.connect("enter_assign_mode", self, "enter_assign_mode")
	Globals.game_world.connect("exit_assign_mode", self, "exit_assign_mode")
	Globals.game_world.connect("enter_raid", self, "enter_raid_mode")
	Globals.game_world.connect("exit_raid", self, "exit_raid_mode")

func enter_raid_mode():
	worker_buttons.get_node("AssignButton").set_disabled(true)

func exit_raid_mode():
	worker_buttons.get_node("AssignButton").set_disabled(false)

func enter_assign_mode(_worker):
	worker_buttons.get_node("AssignButton").set_disabled(true)

func exit_assign_mode():
	assignment.set_text("Currently assigned to: " + Globals.game_world.selected_building.get_node("Worker").current_assigned_building.id as String)
	worker_buttons.get_node("AssignButton").set_disabled(false)

func open(building: Building):
	show()
	title.set_text(building.id)
	level.set_text("Level " + (building.level as String))
	description.set_text(building.description)
	check_upgrade(building)
	if building.id == "Hut":
		upgradeButton.hide()
		assignment.show()
		assignment.set_text("Currently assigned to: " + building.get_node("Worker").current_assigned_building.id as String)
		worker_buttons.show()
	elif building is WorkerBuilding:
		assignment.show()
		assignment.set_text("Workers assigned: " + building.current_workers.size() as String + "/" + building.max_workers as String)
	elif building.id == "Keep":
		assignment.show()
		assignment.set_text("Health: " + building.health as String + "/" + building.max_health as String)
		repairButton.show()
		check_repair(building)
	
	if building is CollectorBuilding or building is Tower:
		var radius = building.radius
		var size = 32 * building.operating_radius + 16
		radius.set_region_rect(Rect2(0,0,size,size))
		radius.set_visible(true)

func close():
	hide()
	worker_buttons.hide()
	assignment.hide()
	upgradeButton.show()
	repairButton.hide()

func load_resources():
	for resource in Globals.resources.keys():
		var new_upgrade_counter = upgrade_counter.instance()
		new_upgrade_counter.set_name(resource)
		new_upgrade_counter.get_child(0).set_texture(Globals.resources[resource].texture)
		new_upgrade_counter.hide()
		upgrade_hbox.add_child(new_upgrade_counter)
		upgrade_counters[resource] = new_upgrade_counter
		
		var new_repair_counter = upgrade_counter.instance()
		new_repair_counter.set_name(resource)
		new_repair_counter.get_child(0).set_texture(Globals.resources[resource].texture)
		new_repair_counter.hide()
		repair_hbox.add_child(new_repair_counter)
		repair_counters[resource] = new_repair_counter

func check_upgrade(building: Building):
	if building.level == 5:
		upgradeButton.hide()
		return
	for counter in upgrade_counters.values():
		counter.hide()
	upgrade_hbox.set_modulate(Color(1,1,1,1))
	upgradeButton.set_disabled(false)
	var upgrade_cost = Globals.object_dict[building.id.to_lower()].get("cost", {})
	upgradeButton.set_tooltip("Level " + (building.level + 1) as String + ": " + building.upgrade_tooltips[building.level - 1])
	for resource in upgrade_cost.keys():
		var counter_label: Label = upgrade_counters[resource].get_child(1)
		counter_label.set_text((upgrade_cost[resource] * building.level) as String)
		if upgrade_cost[resource] * building.level > Globals.resources[resource].value:
			counter_label.set_modulate(Color(1,0.21,0.21))
			upgrade_hbox.set_modulate(Color(1,1,1,0.19))
			upgradeButton.set_disabled(true)
		else:
			counter_label.set_modulate(Color(1,1,1))
		upgrade_counters[resource].show()

func check_repair(building: Keep):
	for counter in repair_counters.values():
		counter.hide()
	repair_hbox.set_modulate(Color(1,1,1,1))
	repairButton.set_disabled(false)
	var repair_multiplier = building.max_health - building.health
	if repair_multiplier == 0:
		repair_hbox.set_modulate(Color(1,1,1,0.19))
		repairButton.set_disabled(true)
		return
	var repair_cost = {"wood": repair_multiplier, "stone": 2*repair_multiplier}
	for resource in repair_cost.keys():
		var counter_label: Label = repair_counters[resource].get_child(1)
		counter_label.set_text(repair_cost[resource] as String)
		if repair_cost[resource] > Globals.resources[resource].value:
			counter_label.set_modulate(Color(1,0.21,0.21))
			repair_hbox.set_modulate(Color(1,1,1,0.19))
			repairButton.set_disabled(true)
		else:
			counter_label.set_modulate(Color(1,1,1))
		repair_counters[resource].show()
	if Globals.is_in_raid == true:
		repair_hbox.set_modulate(Color(1,1,1,0.19))
		repairButton.set_disabled(true)
