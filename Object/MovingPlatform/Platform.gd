tool
extends Node2D

export var speed := 16.0
export(int) var initial_node := 0 setget set_initial_node
export(float, 0.0, 1.0) var initial_position := 0.0 setget set_initial_position
export(int, "Forward", "Backward") var initial_direction := 0
onready var path := get_parent() as Path2D
onready var curve := path.curve
var dir := 1
var cpoint := 0
var nextpoint := 1
var timer := 0.0

func editor_update_position():
	if not Engine.editor_hint or get_parent() == null:
		return
	self.position = get_parent().curve.interpolate(initial_node, sineInOut(initial_position))

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
	prints(initial_node, initial_position)
	if initial_node == 0 and initial_position <= 0.0:
		cpoint = 0
		dir = 1
		nextpoint = 1
		timer = 0.0
	elif initial_node >= curve.get_point_count() and initial_position >= 1.0:
		dir = -1
		cpoint = curve.get_point_count()-1
		nextpoint = curve.get_point_count()-2
		timer = 0.0
	else:
		if initial_direction == 0:
			cpoint = initial_node
			nextpoint = initial_node + 1
			timer = initial_position
			dir = 1
		else:
			dir = -1
			cpoint = initial_node + 1
			nextpoint = initial_node
			timer = 1.0-initial_position
	prints(cpoint, nextpoint, dir, timer)

func cubicInOut(t: float) -> float:
	t *= 2.0
	if t <= 1:
		return (t * t * t) / 2.0
	else:
		t -= 2.0
		return (t * t * t + 2.0) / 2.0

func expInOut(t: float) -> float:
	t *= 2.0
	if t <= 1:
		return pow(2, 10 * t - 10) / 2.0
	else:
		return (2.0 - pow(2, 10 - 10 * t)) / 2.0

func sineInOut(t: float) -> float:
	return (1.0 - cos(PI * t)) / 2.0;

func _physics_process(delta):
	if Engine.editor_hint:
		return
	var frompos := curve.get_point_position(cpoint)
	var topos := curve.get_point_position(nextpoint)
	timer += delta * speed / topos.distance_to(frompos)
	if timer > 1.0:
		timer = 0.0
		if dir == 1:
			if nextpoint+1 >= curve.get_point_count():
				dir = -1
				cpoint = nextpoint
				nextpoint = cpoint - 1
			else:
				nextpoint += 1
				cpoint += 1
		else:
			if nextpoint-1 < 0:
				dir = 1
				nextpoint = 1
				cpoint = 0
			else:
				nextpoint -= 1
				cpoint -= 1
	var pos: Vector2
	if dir == 1:
		pos = curve.interpolate(cpoint, sineInOut(timer))
	else:
		pos = curve.interpolate(nextpoint, sineInOut(1.0-timer))
	var ppos = global_position
	position = pos
	$Polygon2D.global_position = ppos

func do_press():
	print("activate")

func do_release():
	print("deactivate")
