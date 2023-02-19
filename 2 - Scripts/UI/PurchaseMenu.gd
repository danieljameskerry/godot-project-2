extends Control
class_name PurchaseMenu

var objects = Globals.object_dict
onready var categories = {"buildings": $Buildings, "defenses": $Defenses}

onready var selectedButtonRect = $SelectedButtonRect
onready var buildingButton = $TabButtons/BuildingButton
onready var defensesButton = $TabButtons/DefensesButton
onready var current_button = buildingButton
onready var purchase_tabs = {buildingButton: [$Buildings, 0], defensesButton: [$Defenses, 65]}

signal building_selected(building_name)
onready var placing_container = $PlacingContainer
onready var placing_hbox = $PlacingContainer/ColorRect/HBox
onready var placing_label = $PlacingContainer/ColorRect/HBox/Label
onready var placing_counter = preload("res://1 - Scenes/UI/PlacingCounter.tscn")
onready var placing_counters = {}

func _ready():
	buildingButton.connect("pressed", self, "on_button_pressed", [buildingButton])
	defensesButton.connect("pressed", self, "on_button_pressed", [defensesButton])

func on_button_pressed(button: TextureButton):
	MusicManager.button_back.play()
	current_button.set_disabled(false)
	purchase_tabs[current_button][0].hide()
	current_button = button
	current_button.set_disabled(true)
	purchase_tabs[current_button][0].show()
	selectedButtonRect._set_position(Vector2(-72, purchase_tabs[current_button][1]))

func disable_all_items():
	for category in categories.keys():
		var tab = categories[category]
		for item_index in tab.get_item_count():
			tab.set_item_disabled(item_index, true)

func unselect_all():
	for category in categories.keys():
		var tab = categories[category]
		for item_index in tab.get_item_count():
			tab.unselect_all()

func is_anything_selected():
	return purchase_tabs[current_button].is_anything_selected()

func load_resources():
	for resource in Globals.resources.keys():
		var new_placing_counter = placing_counter.instance()
		new_placing_counter.set_name(resource)
		new_placing_counter.get_child(0).set_texture(Globals.resources[resource].texture)
		new_placing_counter.hide()
		placing_hbox.add_child(new_placing_counter)
		placing_counters[resource] = new_placing_counter

func load_items():
	for object in objects.keys():
		if objects[object].can_buy:
			categories[objects[object].category].add_item(object.capitalize(), objects[object].texture)

func update_resources():
	for category in categories.keys():
		var tab = categories[category]
		for item_index in tab.get_item_count():
			update_item(tab, item_index)

func update_item(tab: ItemList, item_index: int):
	var cost = objects[tab.get_item_text(item_index).to_lower()].cost
	for resource in cost.keys():
		if cost[resource] > Globals.resources[resource].value:
			tab.set_item_disabled(item_index, true)
			return
	tab.set_item_disabled(item_index, false)

func open_placing_menu(building_name):
	placing_label.set_text("Placing "+building_name.capitalize()+":")
	var cost = objects[building_name].get("cost", {})
	for resource in cost.keys():
		var counter_label: Label = placing_counters[resource].get_child(1)
		counter_label.set_text(cost[resource] as String)
		placing_counters[resource].show()
	placing_container.show()

func close_placing_menu():
	for counter in placing_counters.values():
		counter.hide()
	placing_container.hide()

func _on_building_selected(item_index):
	if  not purchase_tabs[current_button][0].is_item_disabled(item_index):
		emit_signal("building_selected", purchase_tabs[current_button][0].get_item_text(item_index).to_lower())
