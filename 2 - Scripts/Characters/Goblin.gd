extends Enemy
class_name Goblin

func _ready():
	if randi() % 2 == 1:
		$Sprite.set_texture(preload("res://3 - Textures/Characters/Enemies/SpearGoblin.png"))
