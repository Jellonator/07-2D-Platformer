tool
extends Node2D

enum ButtonMode{IGNORE, ACTIVATE, DEACTIVATE, FORWARD}

export var speed := 16.0
export(int) var initial_node := 0 setget set_initial_node
export(float, 0.0, 1.0) var initial_position := 0.0 setget set_initial_position
export(int, "Forward", "Backward") var initial_direction := 0
export(ButtonMode) var button_mode := ButtonMode.IGNORE
onready var path := get_parent() as Path2D
onready var curve := path.curve
var dir := 1
var current_node := 0
var node_position := 0.0
var button_status := 0
var move_dir := 0.0

func editor_update_position():
	if not Engine.editor_hint or get_parent() == null:
		return
	self.position = get_parent().curve.interpolate(initial_node, initial_position)

func set_initial_node(id: int):
	if Engine.editor_hint and get_parent() != null:
		var n = get_parent().curve.get_point_count() - 1
		initial_node = int(clamp(id, 0, n-1))
		editor_update_position()
	else:
		initial_node = id

func set_initial_position(pos: float):
	initial_position = pos
	if Engine.editor_hint:
		editor_update_position()

func _ready():
	if Engine.editor_hint:
		var n = get_parent().curve.get_point_count() - 1
		initial_node = int(clamp(initial_node, 0, n-1))
		editor_update_position()
		return
	if initial_node == 0 and initial_position <= 0.0:
		current_node = 0
		dir = 1
		node_position = 0.0
	elif initial_node >= curve.get_point_count() and initial_position >= 1.0:
		dir = -1
		current_node = curve.get_point_count()-2
		node_position = 1.0
	else:
		if initial_direction == 0:
			current_node = initial_node
			node_position = initial_position
			dir = 1
		else:
			dir = -1
			current_node = initial_node
			node_position = initial_position

func _physics_process(delta):
	if Engine.editor_hint:
		return
	var frompos := curve.get_point_position(current_node)
	var topos := curve.get_point_position(current_node+1)
	var active := true
	var do_reverse := true
	match button_mode:
		ButtonMode.IGNORE:
			active = true
		ButtonMode.ACTIVATE:
			active = button_status > 0
		ButtonMode.DEACTIVATE:
			active = button_status <= 0
		ButtonMode.FORWARD:
			active = true
			do_reverse = false
			if button_status > 0:
				dir = 1
			else:
				dir = -1
	var target_dir = dir
	if not active:
		target_dir = 0
	if move_dir < target_dir:
		move_dir = clamp(move_dir + delta * 8.0, -1.0, target_dir)
	elif move_dir > target_dir:
		move_dir = clamp(move_dir - delta * 8.0, target_dir, 1.0)
	node_position += move_dir * delta * speed / topos.distance_to(frompos)
	if node_position <= 0.0:
		if current_node == 0:
			node_position = 0
			if do_reverse:
				dir = 1
		else:
			node_position = 1.0
			current_node -= 1
	elif node_position >= 1.0:
		if current_node == curve.get_point_count()-2:
			node_position = 1.0
			if do_reverse:
				dir = -1
		else:
			node_position = 0.0
			current_node += 1
	var pos := curve.interpolate(current_node, node_position)
	var ppos = global_position
	position = pos
	$Polygon2D.global_position = ppos

func do_press():
	button_status += 1

func do_release():
	button_status -= 1
