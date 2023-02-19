extends Node2D
class_name MapObject

onready var sprite = $Sprite

func _ready():
	var rand = randf()
	if rand < 0.3:
		sprite.set_frame(sprite.frame+1)
	elif rand < 0.6:
		sprite.set_frame(sprite.frame+2)
