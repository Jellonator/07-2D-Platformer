tool
extends Node2D

export var grid_position_x := 0 setget set_grid_position_x
export var grid_position_y := 0 setget set_grid_position_y

var ignore_tx := false

func _ready():
	if Engine.editor_hint:
		set_notify_transform(true)

func _notification(what):
	if what == NOTIFICATION_TRANSFORM_CHANGED and not ignore_tx:
		grid_position_x = int(global_position.x / 16)
		grid_position_y = int(global_position.y / 16)
		update_position()

func update_position():
	ignore_tx = true
	self.global_position = Vector2(grid_position_x, grid_position_y) * 16
	ignore_tx = false

func set_grid_position_x(value: int):
	grid_position_x = value
	update_position()

func set_grid_position_y(value: int):
	grid_position_y = value
	update_position()
