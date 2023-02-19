extends Building
class_name Keep

export var max_health: int = 10
onready var health: int = max_health
var damage_reduction: int = 0

func upgrade():
	.upgrade()
	if level == 2:
		max_health += 10
		if not $ColorRect.is_visible():
			$ColorRect.show()
			$ColorRect2.show()
		$ColorRect._set_size(Vector2(34*(health/max_health as float), 2))
	elif level == 3:
		max_health += 15
		if not $ColorRect.is_visible():
			$ColorRect.show()
			$ColorRect2.show()
		$ColorRect._set_size(Vector2(34*(health/max_health as float), 2))
	elif level == 4 or level == 5:
		damage_reduction += 1

func connect_signals():
	.connect_signals()

func get_health() -> int:
	return health

func take_damage(damage: int):
	damage = min(damage - damage_reduction, 1) as int
	if not $ColorRect.is_visible():
		$ColorRect.show()
		$ColorRect2.show()
	health = max(health-damage, 0) as int
	$ColorRect._set_size(Vector2(34*(health/max_health as float), 2))
	if health == 0:
		Globals.game_world.game_over()

func reset_health():
	health = max_health
	if $ColorRect.is_visible():
		$ColorRect.hide()
		$ColorRect2.hide()
