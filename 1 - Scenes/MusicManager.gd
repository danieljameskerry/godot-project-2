extends Node2D

onready var menu_music = $MenuMusic
onready var world_ambience = $WorldAmbience
onready var raid_music = $RaidMusic
onready var button_forward = $ButtonClickForward
onready var button_back = $ButtonClickBack
onready var play = $ButtonPlay
onready var speed_up = $ButtonSpeedUp
onready var start = $Start
onready var place = $Place
onready var portal = $PortalOpen
onready var victory_jingle = $VictoryJingle
onready var raid_warning = $RaidWarning

func get_music_vol() -> float:
	return db2linear(AudioServer.get_bus_volume_db(1))

func get_sfx_vol() -> float:
	return db2linear(AudioServer.get_bus_volume_db(2))

func set_music_vol(value: float):
	AudioServer.set_bus_volume_db(1, linear2db(value))


func set_sfx_vol(value: float):
	AudioServer.set_bus_volume_db(2, linear2db(value))
