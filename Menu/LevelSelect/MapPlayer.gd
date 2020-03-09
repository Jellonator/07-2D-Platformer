tool
extends Node2D

export var grid_position_x := 0 setget set_grid_position_x
export var grid_position_y := 0 setget set_grid_position_y

var ignore_tx := false
var is_moving := false
onready var current_position := Vector2(grid_position_x, grid_position_y)
onready var levelselect = get_parent()

const SPEED := 128.0

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

func try_move_direction(dir: Vector2):
	if is_moving:
		return
	var pos := current_position + dir
	if levelselect.is_available(pos):
		while levelselect.is_available(pos+dir) and not levelselect.is_stop(pos):
			pos += dir
		current_position = pos
		is_moving = true

func _physics_process(delta):
	if not is_moving:
		if Input.is_action_just_pressed("move_left"):
			try_move_direction(Vector2.LEFT)
		if Input.is_action_just_pressed("move_down"):
			try_move_direction(Vector2.DOWN)
		if Input.is_action_just_pressed("move_up"):
			try_move_direction(Vector2.UP)
		if Input.is_action_just_pressed("move_right"):
			try_move_direction(Vector2.RIGHT)
	if is_moving:
		var target := current_position * 16
		var diff := target - global_position
		if diff.length() < SPEED * delta:
			is_moving = false
			global_position = target
		else:
			global_position += diff.normalized() * delta * SPEED
