extends Node2D
class_name GameWorld

var width = 101
var height = 101
var object_grid = Globals.object_grid
var objects = Globals.object_dict
var resources = Globals.resources

var keep_pos = Vector2.ZERO
var keep
var portals

onready var ground: AStarPath = $Ground
var noise = OpenSimplexNoise.new()

var mouse_grid_pos = Vector2.ZERO
var highlighted_building: Building = null
var selected_building: Building = null
onready var user_interface = $CanvasLayer/UserInterface

var building_colours = {
	"wood": preload("res://3 - Textures/Buildings/WoodBuildings.png"),
	"red": preload("res://3 - Textures/Buildings/RedBuildings.png"),
	"cyan": preload("res://3 - Textures/Buildings/CyanBuildings.png"),
	"purple": preload("res://3 - Textures/Buildings/PurpleBuildings.png"),
	"green": preload("res://3 - Textures/Buildings/GreenBuildings.png")}
	
var ghost_building = preload("res://1 - Scenes/UI/GhostBuilding.tscn")
onready var building_menu = $CanvasLayer/UserInterface/BuildingMenu
var current_ghost
var ui_selected_building: String

func _ready():
	Globals.game_world = self
	connect("handle_input", self, "standard_input")
	building_menu.connect_signals()
	user_interface.initialize()
	generate_map()
	MusicManager.world_ambience.play()

func generate_map():
	var settings = Globals.world_settings
	if settings.seed != null:
		seed(settings.seed)
	else:
		randomize()
	noise.seed = randi()
	noise.period = settings.per
	noise.octaves = settings.oct
	if is_connected("handle_input", self, "placing_building_input"):
		exit_placing_mode()
	for child in $YSort.get_children():
			child.queue_free()
	object_grid.clear()
	ground.clear()
	var random_position = Vector2(40, 40) + Vector2(randi() % 21, randi() % 21)
	for x in width:
		for y in height:
			var pos = Vector2(x,y)
			object_grid[pos] = {"id": "-"}
			var rand := 2*(abs(noise.get_noise_2d(x,y)))
			if rand < 0.08 * settings.water_multiplier: #deep water
				ground.set_cellv(pos,0)
			elif rand < 0.18 * settings.water_multiplier: #water
				ground.set_cellv(pos,1)
			elif rand < 0.23 * settings.water_multiplier: #sand
				ground.set_cellv(pos,2)
			else: #grass
				var rand_tile = randf()
				var rand_object = randf()
				var tex = 6
				var tree_chance = 0.1 * settings.tree_multiplier
				if rand < 0.5 + ((settings.water_multiplier - 1) / 10): #light grass
					tex = 3
					tree_chance = 0.02 * settings.tree_multiplier
				if rand_tile < 0.05: #tuft 1
					tex += 1
				elif rand_tile < 0.1: #tuft 2
					tex += 2
				ground.set_cellv(pos,tex)
				if rand_object < 0.02 * settings.rock_multiplier and rand > 0.65:
					place_object("rock", pos)
				elif rand_object < tree_chance:
					place_object("tree", pos)
	
	for x in 3:
		for y in 3:
			if ground.get_cellv(random_position + Vector2(x-1,y-1)) < 3:
				ground.set_cellv(random_position + Vector2(x-1,y-1),3)
	for x in range(random_position.x -25, random_position.x + 26):
		var current_pos = Vector2(x, random_position.y)
		ground.set_cellv(current_pos,9)
		if object_grid[current_pos].id != "-":
			object_grid[current_pos].instance.queue_free()
		object_grid[current_pos].id = "/"
	for y in range(random_position.y -25, random_position.y + 26):
		var current_pos = Vector2(random_position.x, y)
		ground.set_cellv(current_pos,10)
		if object_grid[current_pos].id != "-" and object_grid[current_pos].id != "/":
			object_grid[current_pos].instance.queue_free()
		object_grid[current_pos].id = "/"
	place_object("keep", random_position)
	place_object("portal", random_position + Vector2(25,0))
	place_object("portal", random_position + Vector2(-25,0))
	place_object("portal", random_position + Vector2(0,25))
	place_object("portal", random_position + Vector2(0,-25))
	
	keep = object_grid[random_position].instance
	keep_pos = random_position
	portals = [object_grid[random_position + Vector2(25,0)].instance,
			object_grid[random_position + Vector2(-25,0)].instance,
			object_grid[random_position + Vector2(0,25)].instance,
			object_grid[random_position + Vector2(0,-25)].instance]
	for x in 3:
		for y in 3:
			var current_pos = keep_pos + Vector2(x-1,y-1)
			if object_grid[current_pos].id != "-" and object_grid[current_pos].id != "/" and current_pos != keep_pos:
				object_grid[current_pos].instance.queue_free()
			object_grid[current_pos] = {"id": "keep", "instance": keep}
	user_interface.purchase_menu.update_resources()
	
	ground._add_points()
	ground._connect_points()

#var enemy_path: PoolVector2Array
func check_object_requirements(grid_pos: Vector2) -> bool:
	#var cost = objects[ui_selected_building].get("cost", {})
	#for resource in cost.keys():
		#if cost[resource] > resources[resource].value:
			#return false
	var requirements = objects[ui_selected_building].get("requirements")
	if not requirements:
		return true
	var object = requirements[0]
	var number = requirements[1]
	var radius = requirements[2]
	if object == "plains":
		if ground.get_cellv(grid_pos) > 2 and ground.get_cellv(grid_pos) < 6:
			return true
		return false
	var count = 0
	for x in (2*radius + 1):
		for y in (2*radius + 1):
			if object_grid.get(grid_pos + Vector2(x-radius,y-radius), {"id": "-"}).id == object:
				count += 1
				if count == number:
					return true
	return false

func place_object(object: String, grid_pos: Vector2):
	var new_object = objects[object].scene.instance()
	new_object.set_position(ground.map_to_world(grid_pos))
	$YSort.add_child(new_object)
	if object_grid[grid_pos].id != "-" and object_grid[grid_pos].id != "/":
		object_grid[grid_pos].instance.queue_free()
	object_grid[grid_pos] = {"id": object, "instance": new_object}
	ground._update_point_weight(grid_pos, 10.0)
	if objects[object].is_building:
		new_object.sprite.set_texture(objects[object].texture)
		new_object.connect_signals()
	if objects[object].can_buy:
		var obj_cost = objects[object].cost
		for resource in obj_cost.keys():
			resources[resource].value -= obj_cost[resource]
		user_interface.update_resource_counters()

signal handle_input(event)
func _unhandled_input(event):
	emit_signal("handle_input", event)

func placing_building_input(event):
	mouse_grid_pos = ground.world_to_map(get_global_mouse_position())
	mouse_grid_pos = Vector2(clamp(mouse_grid_pos.x, 0, 99),clamp(mouse_grid_pos.y, 0, 99))
	if event.is_action_pressed("left_click") and current_ghost.get_node("Highlight").get_frame() == 1:
		MusicManager.place.play()
		place_object(ui_selected_building, mouse_grid_pos)
		exit_placing_mode()
	elif event.is_action_pressed("right_click"):
		MusicManager.button_back.play()
		exit_placing_mode()
	elif ground.world_to_map(current_ghost.get_position()) != mouse_grid_pos:
		current_ghost.set_position(ground.map_to_world(mouse_grid_pos))
		if object_grid[mouse_grid_pos].id == "-" and ground.get_cellv(mouse_grid_pos) > 1 and check_object_requirements(mouse_grid_pos):
			current_ghost.get_node("Highlight").set_frame(1)
		else:
			current_ghost.get_node("Highlight").set_frame(3)

func standard_input(event):
	if highlighted_building != null and highlighted_building != selected_building and event.is_action_pressed("left_click"):
		MusicManager.button_forward.play()
		if selected_building != null:
			close_building_menu()
		selected_building = highlighted_building
		highlighted_building = null
		open_building_menu(selected_building)
	elif selected_building != null and event.is_action_pressed("right_click"):
		close_building_menu()

func assign_worker_input(event):
	if event.is_action_pressed("left_click") and highlighted_building is WorkerBuilding and highlighted_building.get_assign_highlight():
		MusicManager.play.play()
		var worker = selected_building.get_node("Worker")
		worker.assign(highlighted_building)
		exit_assign_mode()
	elif event.is_action_pressed("right_click"):
		MusicManager.button_back.play()
		exit_assign_mode()

func _on_UserInterface_building_selected(building_name: String):
	if is_connected("handle_input", self, "placing_building_input"):
		disconnect("handle_input", self, "placing_building_input")
		connect("handle_input", self, "standard_input")
		current_ghost.queue_free()
		user_interface.close_placing_menu()
	elif selected_building != null:
		close_building_menu()
	ui_selected_building = building_name
	enter_placing_mode(objects[building_name].texture)

func enter_placing_mode(building_texture: Texture):
	MusicManager.button_forward.play()
	user_interface.open_placing_menu(ui_selected_building)
	disconnect("handle_input", self, "standard_input")
	connect("handle_input", self, "placing_building_input")
	current_ghost = ghost_building.instance()
	current_ghost.get_node("Sprite").set_texture(building_texture)
	var requirements = objects[ui_selected_building].get("requirements")
	var radius = current_ghost.get_node("Radius")
	if requirements != null:
		var size = 32 * requirements[2] + 16
		radius.set_region_rect(Rect2(0,0,size,size))
		radius.set_visible(true)
	elif objects[ui_selected_building].category == "defenses":
		radius.set_region_rect(Rect2(0,0,80,80))
		radius.set_visible(true)
	$YSort.add_child(current_ghost)

func exit_placing_mode():
	user_interface.close_placing_menu()
	disconnect("handle_input", self, "placing_building_input")
	connect("handle_input", self, "standard_input")
	current_ghost.queue_free()
	user_interface.purchase_menu.unselect_all()

func open_building_menu(building):
	building_menu.open(building)

func close_building_menu():
	selected_building.set_highlight(1)
	if selected_building is Farm or selected_building is Lumbermill or selected_building is Tower:
		selected_building.radius.set_visible(false)
	selected_building = null
	building_menu.close()

func _on_Building_mouse_enter(building):
	highlighted_building = building
	if is_connected("handle_input", self, "standard_input"):
		building.set_highlight(1.2)

func _on_Building_mouse_exit(building):
	if selected_building != building:
		highlighted_building = null
		building.set_highlight(1)

func evaluate_path(start_pos: Vector2, end_pos: Vector2 = ground.map_to_world(keep_pos)) -> PoolVector2Array:
	start_pos = ground.world_to_map(start_pos)
	end_pos = ground.world_to_map(end_pos)
	return ground._get_path(start_pos, end_pos)

func goto_worker():
	MusicManager.button_forward.play()
	var worker = selected_building.get_node("Worker")
	$Camera2D.set_position(worker.get_global_position() + Vector2(8,8))

signal enter_assign_mode(worker)
signal exit_assign_mode

func enter_assign_mode():
	MusicManager.button_forward.play()
	emit_signal("enter_assign_mode", selected_building.get_node("Worker"))
	disconnect("handle_input", self, "standard_input")
	connect("handle_input", self, "assign_worker_input")

func exit_assign_mode():
	emit_signal("exit_assign_mode")
	disconnect("handle_input", self, "assign_worker_input")
	connect("handle_input", self, "standard_input")

func upgrade_building():
	MusicManager.speed_up.play()
	var upgrade_cost = objects[selected_building.id.to_lower()].get("cost", {})
	for resource in upgrade_cost.keys():
		resources[resource].value -= upgrade_cost[resource] * selected_building.level
	user_interface.update_resource_counters()
	selected_building.upgrade()
	building_menu.close()
	building_menu.open(selected_building)


var active_portals
var raid_waves = [
	{"enemies": {"slime": 5}, "portals": 1, "delay": 0.5},
	{"enemies": {"goblin": 10, "orc": 2}, "portals": 2, "delay": 0.25},
	{"enemies": {"orc": 15, "goblin": 16, "kamikaze": 2}, "portals": 3, "delay": 0.167},
	{"enemies": {"kamikaze": 5, "goblin": 32, "orc": 8}, "portals": 4, "delay": 0.125},
	{"enemies": {"orc": 40, "kamikaze": 8, "goblin": 40, "dragon": 1}, "portals": 4, "delay": 0.1}
	]
onready var enemies = {
	"goblin": preload("res://1 - Scenes/Characters/Goblin.tscn"),
	"orc": preload("res://1 - Scenes/Characters/Orc.tscn"),
	"slime": preload("res://1 - Scenes/Characters/Slime.tscn"),
	"kamikaze": preload("res://1 - Scenes/Characters/KamikazeGoblin.tscn"),
	"dragon": preload("res://1 - Scenes/Characters/Dragon.tscn")}
var current_enemy_count: int = 0
signal enter_raid
signal exit_raid

func generate_active_portals(wave: int):
	active_portals = portals.duplicate()
	active_portals.shuffle()
	active_portals  = active_portals.slice(0, raid_waves[wave].portals - 1)
	MusicManager.raid_warning.play()
	for portal in active_portals:
		portal.heads_up()

func enter_raid(wave: int):
	Globals.is_in_raid = true
	emit_signal("enter_raid")
	var wave_enemies = raid_waves[wave].enemies
	MusicManager.portal.play()
	MusicManager.world_ambience.stop()
	MusicManager.raid_music.play()
	for portal in active_portals:
		portal.activate()
	var current_portal_index = 0
	var timer = Clock.new()
	add_child(timer)
	timer.start(raid_waves[wave].delay)
	for enemy_type in wave_enemies.keys():
		for enemy_number in wave_enemies[enemy_type]:
			current_enemy_count += 1
			var new_enemy = enemies[enemy_type].instance()
			var random_portal_position = active_portals[current_portal_index].get_global_position()
			current_portal_index += 1
			if current_portal_index >= active_portals.size():
				current_portal_index = 0
			new_enemy.set_position(random_portal_position)
			new_enemy.connect("damage_keep", keep, "take_damage")
			new_enemy.connect("dead", self, "decrement_enemy_count")
			$YSort.add_child(new_enemy)
			yield(timer, "timeout")
			timer.start(raid_waves[wave].delay)
	timer.queue_free()

func exit_raid():
	Globals.is_in_raid = false
	emit_signal("exit_raid")
	user_interface.next_day()
	for portal in portals:
		portal.deactivate()
	MusicManager.raid_music.stop()
	MusicManager.victory_jingle.play()
	yield(MusicManager.victory_jingle, "finished")
	MusicManager.world_ambience.play()

func decrement_enemy_count():
	current_enemy_count -= 1
	if current_enemy_count < 1 and not keep.get_health() == 0:
		exit_raid()

func repair_keep():
	MusicManager.speed_up.play()
	var repair_multiplier = keep.max_health - keep.health
	var repair_cost = {"wood": repair_multiplier, "stone": 2*repair_multiplier}
	for resource in repair_cost.keys():
		resources[resource].value -= repair_cost[resource]
	user_interface.update_resource_counters()
	keep.reset_health()
	building_menu.close()
	building_menu.open(selected_building)

func game_over():
	user_interface.game_over()
