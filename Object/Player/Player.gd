extends KinematicBody2D

const scene_gelatin := preload("res://Object/Player/Gelatin.tscn")
const TERMINAL_VELOCITY := 400
const MAX_SPEED := 120.0
const MOVE_ACCEL := 800.0
const GRAVITY := 600.0
const GRAVITY_FALL := 2000.0
const JUMP_SPEED := 250.0
const JUMP_SPEED_GRAB := 210.0

var velocity := Vector2()
var grabbed_object = null
var potential_grabs := []

var node_gbl
var node_gbr
var node_gtl
var node_gtr

func set_hbox_ground(on_ground: bool):
	$Air.disabled = on_ground
	$Ray1.disabled = not on_ground
	$Ray2.disabled = not on_ground
#	$CollisionPolygon2D.disabled = not on_ground

func check_joint(node: RigidBody2D):
	pass
#	var diff = node.position - node.original_position
#	var target_
#	if diff.length() > 1e-5:
#		var target_veloc = -diff.normalized() * (diff.length() + 100)
#		node.add_central_force(target_veloc - node.linear_velocity)
#		node.add_central_force(-diff)
#	if (node.position.distance_to(node.original_position) > 8.0):
#		node.tp_to = diff.normalized() * 7.5 + node.original_position

func _ready():
	set_hbox_ground(true)
	node_gtl = scene_gelatin.instance()
	node_gtl.position = $GTL.global_position
	node_gtl.target = $GTL
	get_parent().call_deferred("add_child", node_gtl)
	node_gtr = scene_gelatin.instance()
	node_gtr.position = $GTR.global_position
	node_gtr.target = $GTR
	get_parent().call_deferred("add_child", node_gtr)
	node_gbl = scene_gelatin.instance()
	node_gbl.position = $GBL.global_position
	node_gbl.target = $GBL
	get_parent().call_deferred("add_child", node_gbl)
	node_gbr = scene_gelatin.instance()
	node_gbr.position = $GBR.global_position
	node_gbr.target = $GBR
	get_parent().call_deferred("add_child", node_gbr)
	node_gtl.gravity_scale = 0
	node_gtr.gravity_scale = 0
	yield(get_tree(), "idle_frame")
	for node in [node_gtl, node_gbl, node_gbr, node_gtr]:
		node.pin_to(self)

func _sort_grab(a, b):
	var a_priority = a.get_grab_priority()
	var b_priority = b.get_grab_priority()
	if a_priority != b_priority:
		return a_priority > b_priority
	var sx = global_position.x
	return abs(a.global_position.x - sx) < abs(b.global_position.x - sx)

func get_best_grab():
	if potential_grabs.size() == 0:
		return null
	if potential_grabs.size() == 1:
		return potential_grabs[0]
	potential_grabs.sort_custom(self, "_sort_grab")
	return potential_grabs[0]

func _physics_process(delta: float):
	var prev_veloc := velocity
	if velocity.y < 0 and not Input.is_action_pressed("action_jump"):
		velocity += Vector2(0, 1) * delta * GRAVITY_FALL
	else:
		velocity += Vector2(0, 1) * delta * GRAVITY
	var move_dir := Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	if move_dir < -1e-5:
		$Flip.scale.x = -1.0
	elif move_dir > 1e-5:
		$Flip.scale.x = 1.0
	var target_speed := move_dir * MAX_SPEED
	var accel := MOVE_ACCEL * delta
	if abs(velocity.x - target_speed) < accel:
		velocity.x = target_speed
	elif velocity.x < target_speed:
		velocity.x = clamp(velocity.x + accel, -MAX_SPEED, MAX_SPEED)
	else:
		velocity.x = clamp(velocity.x - accel, -MAX_SPEED, MAX_SPEED)
	velocity.y = min(velocity.y, TERMINAL_VELOCITY)
	var floorveloc := get_floor_velocity() * delta
	velocity += floorveloc
	if is_on_floor():
		velocity = move_and_slide_with_snap(velocity, Vector2(0, 2), Vector2(0, -1), true, 4, 0.785398, false)
	else:
		velocity = move_and_slide(velocity, Vector2(0, -1), true, 4, 0.785398, false)
	set_hbox_ground(is_on_floor())
	velocity -= floorveloc
	var total_accel := velocity - prev_veloc
	for node in [node_gbl, node_gbr]:
		node.force += total_accel * Vector2(1, -1) * delta * 150
	for node in [node_gbl, node_gbr, node_gtl, node_gtr]:
		node.force += velocity * delta * 21.0
	if Input.is_action_just_pressed("action_grab"):
		if grabbed_object != null:
			grabbed_object.grab_end()
			var veloc := Vector2.ZERO
			if not Input.is_action_pressed("move_down"):
				veloc += velocity
				if is_on_floor():
					var dir = ($Flip/DropPosition.global_position - $Flip/GrabPosition.global_position).normalized()
					veloc += dir * 60.0
			grabbed_object.teleport_to($Flip/GrabPosition.global_position, true)
			grabbed_object.apply_impulse(Vector2.ZERO, veloc)
			grabbed_object = null
		elif potential_grabs.size() > 0:
			if is_on_floor():
				grabbed_object = get_best_grab()
				grabbed_object.grab_begin()
				grabbed_object.teleport_to($Flip/GrabPosition.global_position, false)
	elif grabbed_object != null:
		grabbed_object.teleport_to($Flip/GrabPosition.global_position, true)
	check_joint(node_gbl)
	check_joint(node_gbr)
	check_joint(node_gtl)
	check_joint(node_gtr)
	var tx = $Polygon2D.global_transform
	var tl = tx.xform_inv(node_gtl.global_position + Vector2(-2, -2))
	var tr = tx.xform_inv(node_gtr.global_position + Vector2(2, -2))
	var bl = tx.xform_inv(node_gbl.global_position + Vector2(-2, 2))
	var br = tx.xform_inv(node_gbr.global_position + Vector2(2, 2))
#	$Polygon2D.polygon.set(0, tl)
#	$Polygon2D.polygon.set(1, tr)
#	$Polygon2D.polygon.set(2, br)
#	$Polygon2D.polygon.set(3, bl)
	$Polygon2D.polygon = PoolVector2Array([tl, tr, br, bl])
	$Polygon2D.update()

func _input(event):
	if event.is_action_pressed("action_jump") and is_on_floor():
		set_hbox_ground(false)
		if grabbed_object != null:
			velocity.y = -JUMP_SPEED_GRAB
		else:
			velocity.y = -JUMP_SPEED

func _on_GrabArea_body_entered(body):
	potential_grabs.append(body)

func _on_GrabArea_body_exited(body):
	potential_grabs.erase(body)

func do_kill():
	var path = get_tree().current_scene.filename
	var err = get_tree().change_scene(path)
	if err != OK:
		push_error("Could not kill >:( (tried to load{0} [{1}])".format([path, err]))
