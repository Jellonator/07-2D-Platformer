extends Node2D

onready var map := $TileMap

var stops := {}

onready var node_display := $CanvasLayer/Display

func is_available(pos: Vector2, dir: Vector2) -> bool:
	if is_stop(pos):
		var stop = get_stop(pos)
		if stop.has_method("can_move_direction"):
			if not stop.can_move_direction(dir):
				return false
	return map.get_cellv(pos + dir) != TileMap.INVALID_CELL

func is_available_at(pos: Vector2) -> bool:
	return map.get_cellv(pos) != TileMap.INVALID_CELL

func is_stop(pos: Vector2) -> bool:
	return pos in stops

func get_stop(pos: Vector2):
	return stops[pos]

func _ready():
	node_display.hide()
	for stop in get_tree().get_nodes_in_group("stop"):
		var pos = Vector2(stop.grid_position_x, stop.grid_position_y)
		stops[pos] = stop

func start_move():
	node_display.hide()

func stop_at(pos: Vector2):
	if pos in stops:
		var stop = stops[pos]
		if stop.has_method("get_level_title"):
			node_display.show()
			node_display.get_node("Title").text = stop.get_level_title()
			node_display.get_node("Num").text = stop.get_film_text()

func activate_at(pos: Vector2):
	if pos in stops:
		var stop = stops[pos]
		if stop.has_method("activate"):
			stop.activate()
