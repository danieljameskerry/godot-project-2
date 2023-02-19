extends TileMap
class_name AStarPath

onready var astar = AStar2D.new()
var used_cells: Array

func clear():
	.clear()
	astar.clear()
	used_cells.clear()

func _add_points():
	for cell in get_used_cells():
		if Globals.object_grid[cell].id != "-" and Globals.object_grid[cell].id != "/":
			used_cells.append(cell)
			astar.add_point(id(cell), cell, 10.0)
		elif get_cellv(cell) == 0:
			used_cells.append(cell)
			astar.add_point(id(cell), cell, 50.0)
		elif get_cellv(cell) == 1:
			used_cells.append(cell)
			astar.add_point(id(cell), cell, 30.0)
		elif get_cellv(cell) == 2:
			used_cells.append(cell)
			astar.add_point(id(cell), cell, 2.0)
		elif get_cellv(cell) > 2:
			used_cells.append(cell)
			astar.add_point(id(cell), cell, 1.0)

func _update_point_weight(cell: Vector2, weight: float):
	if astar.has_point(id(cell)):
		astar.set_point_weight_scale(id(cell), weight)

func _connect_points():
	for cell in used_cells:
		var neighbors = [Vector2.RIGHT, Vector2.LEFT, Vector2.UP, Vector2.DOWN]
		for neighbor in neighbors:
			var next_cell = cell + neighbor
			if used_cells.has(next_cell):
				astar.connect_points(id(cell), id(next_cell), false)

func _get_path(start, end) -> PoolVector2Array:
	var path: PoolVector2Array = astar.get_point_path(id(start), id(end))
	path.remove(0)
	return path

func id(point):
	return (point.x + point.y) * (point.x + point.y + 1) / 2 + point.y
