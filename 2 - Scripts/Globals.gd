extends Node

var game_world: GameWorld
var world_settings = {"per": 80, "oct": 5, "seed": null, "water_multiplier": 0, "tree_multiplier": 1, "rock_multiplier": 1}
var game_speed: int = 1
var is_in_raid: bool = false

signal speed_changed
func adjust_speed(speed: int):
	game_speed = speed
	emit_signal("speed_changed")

#"coords": {"id": //, "instance": //}
var object_grid = {}
var worker_claimed_objects = {}

var resources = {
	"food": {
		"value": 20,
		"texture": preload("res://4 - Resources/UI/food.tres")},
	"wood": {
		"value": 20,
		"texture": preload("res://4 - Resources/UI/wood.tres")},
	"stone": {
		"value": 20,
		"texture": preload("res://4 - Resources/UI/stone.tres")},
	"metal": {
		"value": 0,
		"texture": preload("res://4 - Resources/UI/metal.tres")}
	}

#"object name": {"scene": //, "is_building": //, "region": //, "cost": [//,//], "requirements": [//,//]}
var object_dict = {
	"tree": {"is_building": false, "can_buy": false,
		"scene": preload("res://1 - Scenes/MapObjects/Tree.tscn")},
	"rock": {"is_building": false, "can_buy": false,
		"scene": preload("res://1 - Scenes/MapObjects/Rock.tscn")},
	
	"portal": {"is_building": false, "can_buy": false,
		"scene": preload("res://1 - Scenes/MapObjects/Portal.tscn")},
	
	"keep" : {"is_building": true, "can_buy": false,
		"scene": preload("res://1 - Scenes/Buildings/Keep.tscn"),
		"texture": preload("res://4 - Resources/Buildings/keep.tres"),
		"cost": {"wood": 10, "stone": 10},
		"requirements": ["-",9,1]},
	"hut": {"is_building": true, "can_buy": true, "category": "buildings",
		"scene": preload("res://1 - Scenes/Buildings/Hut.tscn"),
		"texture": preload("res://4 - Resources/Buildings/hut.tres"),
		"cost": {"food": 5, "wood": 5}},
	"farm": {"is_building": true, "can_buy": true, "category": "buildings",
		"scene": preload("res://1 - Scenes/Buildings/Farm.tscn"),
		"texture": preload("res://4 - Resources/Buildings/farm.tres"),
		"cost": {"wood": 10},
		"requirements": ["plains",0,2]},
	"mine": {"is_building": true, "can_buy": true, "category": "buildings",
		"scene": preload("res://1 - Scenes/Buildings/Mine.tscn"), 
		"texture": preload("res://4 - Resources/Buildings/mine.tres"),
		"cost": {"wood": 5, "stone": 10},
		"requirements": ["rock",1,1]},
	"lumbermill": {"is_building": true, "can_buy": true, "category": "buildings",
		"scene": preload("res://1 - Scenes/Buildings/Lumbermill.tscn"),
		"texture": preload("res://4 - Resources/Buildings/lumbermill.tres"),
		"cost": {"wood": 10, "stone": 5},
		"requirements": ["tree",4,3]},
	"farmland": {"is_building": false, "can_buy": true, "category": "buildings",
		"scene": preload("res://1 - Scenes/MapObjects/Farmland.tscn"),
		"texture": preload("res://4 - Resources/Buildings/farmland.tres"),
		"cost": {"food": 2}},
	
	"archer tower": {"is_building": true, "can_buy": true, "category": "defenses",
		"scene": preload("res://1 - Scenes/Buildings/ArcherTower.tscn"),
		"texture": preload("res://4 - Resources/Buildings/tower.tres"),
		"cost": {"food": 5, "wood": 5, "stone": 10}},
	"musketeer tower": {"is_building": true, "can_buy": true, "category": "defenses",
		"scene": preload("res://1 - Scenes/Buildings/MusketeerTower.tscn"),
		"texture": preload("res://4 - Resources/Buildings/tower.tres"),
		"cost": {"food": 5, "wood": 5, "stone": 10, "metal": 5}},
	"mage tower": {"is_building": true, "can_buy": true, "category": "defenses",
		"scene": preload("res://1 - Scenes/Buildings/MageTower.tscn"),
		"texture": preload("res://4 - Resources/Buildings/tower.tres"),
		"cost": {"food": 5, "wood": 5, "stone": 10, "metal": 5}}
	}
