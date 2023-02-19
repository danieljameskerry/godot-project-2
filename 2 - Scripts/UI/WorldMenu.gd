extends Node2D
class_name WorldMenu

var objects = Globals.object_dict

var width = 101
var height = 101
onready var ground = $ViewScaler/Ground
onready var ysort = $ViewScaler/YSort
var noise = OpenSimplexNoise.new()

onready var seed_input = $CanvasLayer/Control/Settings/Seed/TextEdit
var current_seed: int = 0

var current_water_multiplier: float = 1
var current_tree_multiplier: float = 1
var current_rock_multiplier: float = 1

func _ready():
	randomize()
	var random_seed = randi() % 999999999999999999
	current_seed = random_seed
	seed_input.set_text(random_seed as String)
	request_map_update()

func on_seed_changed():
	if seed_input.get_text() as int != current_seed:
		current_seed = seed_input.get_text() as int
		request_map_update()

func generate_random_seed():
	MusicManager.speed_up.play()
	randomize()
	var random_seed = randi() % 999999999999999999
	current_seed = random_seed
	seed_input.set_text(random_seed as String)
	request_map_update()

func change_water_level(value: float):
	MusicManager.button_forward.play()
	if current_water_multiplier != value / 100:
		current_water_multiplier = value / 100
		request_map_update()

func change_tree_level(value: float):
	MusicManager.button_forward.play()
	if current_tree_multiplier != value / 100:
		current_tree_multiplier = value / 100
		request_map_update()

func change_rock_level(value):
	MusicManager.button_forward.play()
	if current_rock_multiplier != value / 100:
		current_rock_multiplier = value / 100
		request_map_update()

var request_pending = false
func request_map_update():
	if request_pending:
		return
	if $Cooldown.get_time_left() == 0:
		$Cooldown.start()
		generate_map()
		return
	request_pending = true
	yield($Cooldown, "timeout")
	generate_map()
	request_pending = false

func generate_map(per: int = 80, oct: int = 5, _seed: int = current_seed):
	seed(_seed)
	noise.seed = randi()
	noise.period = per
	noise.octaves = oct
	for child in ysort.get_children():
			child.queue_free()
	ground.clear()
	var random_position = Vector2(40, 40) + Vector2(randi() % 21, randi() % 21)
	for x in width:
		for y in height:
			var pos = Vector2(x,y)
			var rand := 2*(abs(noise.get_noise_2d(x,y)))
			#var distance = Vector2(100-x,100-y).length()
			if rand < 0.08 * current_water_multiplier: #deep water
				ground.set_cellv(pos,0)
			elif rand < 0.18 * current_water_multiplier: #water
				ground.set_cellv(pos,1)
			elif rand < 0.23 * current_water_multiplier: #sand
				ground.set_cellv(pos,2)
			else: #grass
				var rand_tile = randf()
				var rand_object = randf()
				var tex = 6
				var tree_chance = 0.1 * current_tree_multiplier
				if rand < 0.5 + ((current_water_multiplier - 1) / 10): #light grass
					tex = 3
					tree_chance = 0.02 * current_tree_multiplier
				if rand_tile < 0.05: #tuft 1
					tex += 1
				elif rand_tile < 0.1: #tuft 2
					tex += 2
				ground.set_cellv(pos,tex)
				if rand_object < 0.02 * current_rock_multiplier and rand > 0.65:
					place_object("rock", pos)
				elif rand_object < tree_chance:
					place_object("tree", pos)
	
	place_object("keep", random_position)
	place_object("portal", random_position + Vector2(25,0))
	place_object("portal", random_position + Vector2(-25,0))
	place_object("portal", random_position + Vector2(0,25))
	place_object("portal", random_position + Vector2(0,-25))
	for x in 3:
		for y in 3:
			if ground.get_cellv(random_position + Vector2(x-1,y-1)) < 3:
				ground.set_cellv(random_position + Vector2(x-1,y-1),3)
	for x in range(random_position.x -25, random_position.x + 26):
		ground.set_cell(x,random_position.y,9)
	for y in range(random_position.y -25, random_position.y + 26):
		ground.set_cell(random_position.x,y,10)

func place_object(object: String, grid_pos: Vector2):
	var new_object = objects[object].scene.instance()
	new_object.set_position(ground.map_to_world(grid_pos))
	ysort.add_child(new_object)

func play():
	Globals.world_settings.seed = current_seed
	Globals.world_settings.water_multiplier = current_water_multiplier
	Globals.world_settings.tree_multiplier = current_tree_multiplier
	Globals.world_settings.rock_multiplier = current_rock_multiplier
	MusicManager.start.play()
	MusicManager.menu_music.stop()
	get_tree().change_scene("res://1 - Scenes/World.tscn")


func goto_main():
	MusicManager.button_back.play()
	get_tree().change_scene("res://1 - Scenes/MainMenu.tscn")
