extends Node2D

onready var map := $TileMap

var stops := {}

func is_available(pos: Vector2) -> bool:
	return map.get_cellv(pos) != TileMap.INVALID_CELL

func is_stop(pos: Vector2) -> bool:
	return pos in stops

func get_stop(pos: Vector2):
	return stops[pos]

func _ready():
	for stop in get_tree().get_nodes_in_group("stop"):
		var pos = Vector2(stop.grid_position_x, stop.grid_position_y)
		stops[pos] = stop
