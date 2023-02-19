extends Control
class_name UserInterface

var objects = Globals.object_dict
var resources = Globals.resources

onready var resource_bar = $ColorRect/ResourceBar
onready var resource_counter = preload("res://1 - Scenes/UI/ResourceCounter.tscn")
onready var resource_counters = {}

signal building_selected(building_name)
onready var purchase_menu = $PurchaseMenu
onready var building_menu = $BuildingMenu

func initialize():
	load_resources()
	purchase_menu.load_items()
	purchase_menu.load_resources()
	update_resource_counters()

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel") and not $GameOverMenu.is_visible():
		if $PauseMenu.is_visible():
			if $PauseMenu/Options.is_visible():
				close_options()
			else:
				close_pause_menu()
		else:
			open_pause_menu()
		get_tree().set_input_as_handled()

func update_resource_counters():
	for resource in resources.keys():
		resource_counters[resource].set_text(resources[resource].value as String)
	purchase_menu.update_resources()
	if Globals.game_world.selected_building != null:
		building_menu.check_upgrade(Globals.game_world.selected_building)

func load_resources():
	for resource in resources.keys():
		var new_resource_counter = resource_counter.instance()
		new_resource_counter.set_name(resource)
		new_resource_counter.get_child(0).set_texture(resources[resource].texture)
		resource_bar.add_child(new_resource_counter)
		resource_counters[resource] = new_resource_counter.get_child(1)

func open_placing_menu(building_name):
	purchase_menu.open_placing_menu(building_name)

func close_placing_menu():
	purchase_menu.close_placing_menu()

func _on_building_selected(building_name: String):
	emit_signal("building_selected", building_name)

func open_pause_menu():
	MusicManager.button_back.play()
	$PauseMenu.show()
	get_tree().set_pause(true)

func close_pause_menu():
	MusicManager.play.play()
	$PauseMenu.hide()
	get_tree().set_pause(false)

func open_options():
	MusicManager.button_forward.play()
	$PauseMenu/Pause.hide()
	$PauseMenu/Options.show()

func close_options():
	MusicManager.button_back.play()
	$PauseMenu/Options.hide()
	$PauseMenu/Pause.show()

func change_music_vol(value: float):
	MusicManager.change_music_vol(value)

func change_sfx_vol(value: float):
	MusicManager.change_sfx_vol(value)

func exit_to_menu():
	MusicManager.world_ambience.stop()
	MusicManager.start.play()
	yield(MusicManager.start, "finished")
	MusicManager.menu_music.play()
	get_tree().set_pause(false)
	get_tree().change_scene("res://1 - Scenes/MainMenu.tscn")

func next_day():
	$SpeedController.next_day()

func game_over():
	$SpeedController.on_button_pressed($SpeedController.pauseButton)
	$GameOverMenu.show()
