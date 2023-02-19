extends Node2D
class_name Building

export var id: String = "Building"
export (String, MULTILINE) var description = "This is a building, no description needed."
var level: int = 1
export var upgrade_tooltips = ["x2 yield","+2 max workers","+2 range","x2 yield"]

onready var sprite = $Sprite
onready var DetectionArea = $Area2D

func connect_signals():
	DetectionArea.connect("mouse_entered", Globals.game_world, "_on_Building_mouse_enter", [self])
	DetectionArea.connect("mouse_exited", Globals.game_world, "_on_Building_mouse_exit", [self])

func set_highlight(highlight: float):
	sprite.set_scale(Vector2(highlight, highlight))

func upgrade():
	level += 1
