extends Building
class_name Tower

export var damage: int = 1
enum projectile_types {arrow, fireball, bullet}
export (projectile_types) var projectile_type
var operating_radius = 2
onready var radius = $Radius
var enemies_in_range = []
var is_attacking = false
var current_target: Enemy
export var projectile = preload("res://1 - Scenes/Characters/Projectile.tscn")

func upgrade():
	.upgrade()
	if level == 2 or level == 5:
		damage *= 2
	elif level == 3:
		operating_radius += 2
		$DetectionArea/CollisionShape2D.get_shape().set_extents(Vector2(88,88))
	elif level == 4:
		$AnimationPlayer.anim_speed *= 2
		$AnimationPlayer.adjust_speed_scale()

func _on_DetectionArea_enemy_entered(area):
	var enemy = area.get_parent() as Enemy
	if not enemy.is_connected("dead", self, "remove_enemy"):
		enemy.connect("dead", self, "remove_enemy", [enemy])
	enemies_in_range.append(enemy)
	if not is_attacking:
		attack_nearest_enemy()

func _on_DetectionArea_enemy_exited(area):
	enemies_in_range.erase(area.get_parent() as Enemy)

func attack_nearest_enemy():
	is_attacking = true
	current_target = enemies_in_range[0]
	for enemy in enemies_in_range:
		if (enemy.get_position() - get_position()).length_squared() < (current_target.get_position() - get_position()).length_squared():
			current_target = enemy
	var direction = get_position() - current_target.get_position()
	if direction.x > direction.y:
		if direction.x > -direction.y:
			$AnimationPlayer.play("ShootLeft")
		else:
			$AnimationPlayer.play("ShootDown")
	elif direction.x > -direction.y:
		$AnimationPlayer.play("ShootUp")
	else:
		$AnimationPlayer.play("ShootRight")
	yield($AnimationPlayer, "animation_finished")
	if not enemies_in_range.empty():
		attack_nearest_enemy()
		return
	is_attacking = false
	$AnimationPlayer.play("Idle")

var interrupt_fire: bool = false

func fire_shot():
	if not current_target:
		if not enemies_in_range.empty():
			attack_nearest_enemy()
		return
	var new_projectile = projectile.instance()
	new_projectile.set_type(projectile_type)
	new_projectile.get_child(0).set_rotation((current_target.get_position() - get_position()).angle()-(PI/2))
	new_projectile.target = current_target.get_position()
	new_projectile.velocity = (current_target.get_position() - get_position()).normalized()
	get_parent().add_child(new_projectile)
	new_projectile.set_position(get_position())
	yield(new_projectile, "target_reached")
	if new_projectile.has_node("Area2D"):
		for area in new_projectile.area.get_overlapping_areas():
			area.get_parent().take_damage(damage)
	elif current_target:
		current_target.take_damage(damage)
	new_projectile.queue_free()

func remove_enemy(enemy):
	if enemy == current_target:
		current_target = null
	enemies_in_range.erase(enemy)
