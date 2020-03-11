tool
extends Node2D

enum ButtonMode {
	# Ignores the state of the button and continually moves. Will reverse when
	# reaching the end of the path.
	IGNORE,
	# Ignores the state of the button and continually moves until reaching the
	# end of the path.
	IGNORE_FORWARD, 
	# Moves while the button is pressed. Will revese when reaching the end
	# of the path.
	ACTIVATE,
	# Moves while the button is pressed. Does not reverse when reaching the
	# end of the path.
	ACTIVATE_FORWARD,
	# Moves while the button is not pressed. Will revese when reaching the end
	# of the path.
	DEACTIVATE,
	# Moves while the button is not pressed. Does not reverse when reaching the
	# end of the path.
	DEACTIVATE_FORWARD,
	# moves forward while the button is pressed, and moves backwards while the
	# button is not pressed. The direction that the platform moves depends on
	# 'initial_direction'; the platform will move in its initial direction while
	# the button is pressed.
	FORWARD
}

# The speed (in px/s that the platform will move)
export(float) var speed := 16.0
# The initial node that the platform will start at.
export(int) var initial_node := 0 setget set_initial_node
# The initial position within the node that the platform will start at.
export(float, 0.0, 1.0) var initial_position := 0.0 setget set_initial_position
# The initial direction that the platform will move.
export(int, "Forward", "Backward") var initial_direction := 0
# The button mode of this platform.
export(ButtonMode) var button_mode := ButtonMode.IGNORE
export(bool) var button_oneshot := false
export(bool) var display_graphic := true
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
	else:
		if not display_graphic:
			$Polygon2D.hide()
	current_node = initial_node
	node_position = initial_position
	if initial_direction == 0:
		dir = 1
	else:
		dir = -1

func _physics_process(delta):
	if Engine.editor_hint:
		return
	var frompos := curve.get_point_position(current_node)
	var topos := curve.get_point_position(current_node+1)
	var active := true
	var do_reverse := true
	match button_mode:
		ButtonMode.IGNORE:
			pass
		ButtonMode.IGNORE_FORWARD:
			do_reverse = false
		ButtonMode.ACTIVATE:
			active = button_status > 0
		ButtonMode.DEACTIVATE:
			active = button_status <= 0
		ButtonMode.ACTIVATE_FORWARD:
			active = button_status > 0
			do_reverse = false
		ButtonMode.DEACTIVATE_FORWARD:
			active = button_status <= 0
			do_reverse = false
		ButtonMode.FORWARD:
			active = true
			do_reverse = false
			if button_status > 0:
				dir = initial_direction
			else:
				dir = -initial_direction
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
	if not button_oneshot:
		button_status -= 1
