extends Control

func _ready():
	$VBoxContainer/MusicVolume/HSlider.set_value(MusicManager.get_music_vol())
	$VBoxContainer/SFXVolume/HSlider.set_value(MusicManager.get_sfx_vol())

func change_music_vol(value: float):
	MusicManager.set_music_vol(value)

func change_sfx_vol(value: float):
	MusicManager.set_sfx_vol(value)
