extends Node2D

export var speed := 16.0
onready var path := get_parent() as Path2D
onready var curve := path.curve as Curve2D
var dir := 1
var cpoint := 0
var nextpoint := 1
var timer := 0.0

func _ready():
	pass

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
