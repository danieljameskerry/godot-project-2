extends Character
class_name Enemy

export var max_health: int = 1
export var damage: int = 1
onready var health = max_health
signal dead
signal damage_keep(damage)

func _ready():
	$Area2D.set_collision_layer_bit(2, true)
	set_destination(Globals.game_world.keep_pos * 16)

func process_next_behaviour():
	emit_signal("damage_keep", damage)
	emit_signal("dead")
	queue_free()

func take_damage(incoming_damage: int):
	health = max(health-incoming_damage, 0)
	$ColorRect._set_size(Vector2(14*(health/max_health as float), 2))
	if health == 0:
		emit_signal("dead")
		queue_free()
