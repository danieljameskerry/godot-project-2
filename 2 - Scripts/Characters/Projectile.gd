extends Node2D
class_name Projectile

var target: Vector2
var velocity: Vector2
var speed: float = 120
signal target_reached

func set_type(type: int):
	$Sprite.set_frame(type)
	if type == 1:
		speed /= 1.5
		$Sprite.set_scale(Vector2(1.3, 1.3))

func _physics_process(delta):
	position += velocity * delta * Globals.game_speed * speed
	if (position - target).length_squared() < 100:
		emit_signal("target_reached")
