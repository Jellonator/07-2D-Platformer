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
var walk_timer := 0.0
var timer_ground := 0.0
var timer_air := 0.0

# End animation stuff
var is_stopped := false
var stop_anim_movement := 0.0

var node_gbl
var node_gbr
var node_gtl
var node_gtr
var node_face

onready var node_face_sprite := $Sprite

func begin_stop():
	is_stopped = true
	$GrabIcon.hide()

func begin_walk_anim(value: float):
	stop_anim_movement = value

func has_camera() -> bool:
	if grabbed_object == null:
		return false
	return grabbed_object.is_in_group("camera")

func _ready():
	update_grab_icon("action_grab")
	update_grab_icon("action_jump")
	update_grab_icon("action_restart")
# warning-ignore:return_value_discarded
	GameConfig.connect("icon_changed", self, "update_grab_icon")
	node_gtl = scene_gelatin.instance()
	node_gtl.position = $GTL.global_position
	node_gtl.target = $GTL
	node_gtr = scene_gelatin.instance()
	node_gtr.position = $GTR.global_position
	node_gtr.target = $GTR
	node_gbl = scene_gelatin.instance()
	node_gbl.position = $GBL.global_position
	node_gbl.target = $GBL
	node_gbr = scene_gelatin.instance()
	node_gbr.position = $GBR.global_position
	node_gbr.target = $GBR
	node_face = scene_gelatin.instance()
	node_face.position = $GFACE.global_position
	node_face.target = $GFACE
	node_gtl.gravity_scale = 0
	node_gtr.gravity_scale = 0
	node_face.gravity_scale = 0
	yield(get_tree(), "physics_frame")
	for node in [node_gtl, node_gbl, node_gbr, node_gtr, node_face]:
		get_parent().add_child(node)
		node.pin_to(self)
		node.hide()

func update_grab_icon(name: String):
	match name:
		"action_grab":
			$GrabIcon.texture = GameConfig.get_action_icon("action_grab")
		"action_jump":
			$JumpIcon.texture = GameConfig.get_action_icon("action_jump")
		"action_restart":
			$RestartIcon.texture = GameConfig.get_action_icon("action_restart")

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
	if is_on_floor():
		timer_air = 0
		timer_ground += delta
	else:
		timer_ground = 0
		timer_air += delta
	var prev_veloc := velocity
	if not is_on_floor():
		if velocity.y < 0 and not Input.is_action_pressed("action_jump"):
			velocity += Vector2(0, 1) * delta * GRAVITY_FALL
		else:
			velocity += Vector2(0, 1) * delta * GRAVITY
	else:
		velocity += Vector2(0, 1) * delta * 100.0
	var move_dir := Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	if is_stopped:
		move_dir = stop_anim_movement
	if move_dir < -1e-5:
		$Flip.scale.x = -1.0
		$Sprite.flip_h = true
	elif move_dir > 1e-5:
		$Flip.scale.x = 1.0
		$Sprite.flip_h = false
	var target_speed := move_dir * MAX_SPEED
	var accel := MOVE_ACCEL * delta
	if is_stopped:
		accel *= 0.5
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
		velocity = move_and_slide_with_snap(velocity, Vector2(0, 2),\
				Vector2(0, -1), true, 4, 0.785398, false)
	else:
		velocity = move_and_slide(velocity, Vector2(0, -1),\
				true, 4, 0.785398, false)
	velocity -= floorveloc
	###### 
	if is_on_floor():
		if timer_air > 5.0 / 60.0:
			$SfxLand.play()
		walk_timer += delta * velocity.x * 0.04
		var arot := Vector2(1, 0).rotated(walk_timer*PI*2)
		var brot := Vector2(-1, 0).rotated(walk_timer*PI*2)
		node_gbl.force += arot * velocity.length() * 0.3
		node_gbr.force += brot * velocity.length() * 0.3
		if walk_timer > 1.0:
			walk_timer = 0.0
		if walk_timer < 0.0:
			walk_timer = 1.0
	var total_accel := velocity - prev_veloc
	for node in [node_gbl, node_gbr]:
		node.force += total_accel * Vector2(1, 0) * delta * 150
	node_face.force += total_accel * Vector2(1, 0) * delta * 70
	for node in [node_gbl, node_gbr, node_gtl, node_gtr, node_face]:
		node.force += velocity * delta * 21.0
	if node_face.is_inside_tree():
		var tx = $Polygon2D.global_transform
		var tl = tx.xform_inv(node_gtl.global_position + Vector2(-2, -2))
		var tr = tx.xform_inv(node_gtr.global_position + Vector2(2, -2))
		var bl = tx.xform_inv(node_gbl.global_position + Vector2(-2, 2))
		var br = tx.xform_inv(node_gbr.global_position + Vector2(2, 2))
		node_face_sprite.offset = node_face.global_position - node_face.target.global_position
		$Polygon2D.polygon = PoolVector2Array([tl, tr, br, bl])
		$Polygon2D.update()
	###### GRAB OBJECT CODE ######
	var topos = $Flip/GrabPosition.global_position
	if Input.is_action_just_pressed("action_grab") and not is_stopped:
		if grabbed_object != null:
			drop_grabbed_object()
		elif potential_grabs.size() > 0:
			if is_on_floor():
				set_grabbed_object(get_best_grab())
	elif grabbed_object != null:
		grabbed_object.teleport_to(topos, true, get_camera_offset())

func get_camera_offset() -> Vector2:
	if not node_face.is_inside_tree():
		return Vector2.ZERO
	return node_face.get_diff() * 0.4 +\
		node_gtl.get_diff() * 0.2 + node_gtr.get_diff() * 0.2 +\
		node_gbl.get_diff() * 0.1 + node_gbr.get_diff() * 0.1

func drop_grabbed_object():
	var topos = $Flip/GrabPosition.global_position
	grabbed_object.grab_end()
	var veloc := Vector2.ZERO
	if not Input.is_action_pressed("move_down"):
		if Input.is_action_pressed("move_up"):
			veloc += (Vector2(1, -2) * $Flip.scale).normalized() * 120
		else:
			veloc += (Vector2(1, -1) * $Flip.scale).normalized() * 100
		if not is_on_floor():
			veloc.y = 0
		veloc += velocity
	grabbed_object.teleport_to(topos, true, get_camera_offset())
	grabbed_object.apply_central_impulse(veloc)
	grabbed_object = null

func set_grabbed_object(object):
	if grabbed_object != null:
		drop_grabbed_object()
	var topos = $Flip/GrabPosition.global_position
	grabbed_object = object
	grabbed_object.grab_begin()
	grabbed_object.teleport_to(topos, false, get_camera_offset())

func _input(event):
	if event.is_action_pressed("action_jump") and is_on_floor() and not is_stopped:
		if grabbed_object != null:
			velocity.y = -JUMP_SPEED_GRAB
		else:
			velocity.y = -JUMP_SPEED
		$SfxJump.play()

func _on_GrabArea_body_entered(body):
	potential_grabs.append(body)
	$GrabIcon.visible = (potential_grabs.size() > 0 or grabbed_object != null) and\
			get_tree().current_scene.unique_name == "level1" and not is_stopped

func _on_GrabArea_body_exited(body):
	potential_grabs.erase(body)
	$GrabIcon.visible = (potential_grabs.size() > 0 or grabbed_object != null) and\
			get_tree().current_scene.unique_name == "level1" and not is_stopped

func do_kill():
	if is_stopped:
		return
	var path = get_tree().current_scene.filename
	var err = get_tree().change_scene(path)
	if err != OK:
		push_error("Could not kill >:( (tried to load{0} [{1}])".format([path, err]))

func show_jump_icon():
	$JumpIcon.show()

func hide_jump_icon():
	$JumpIcon.hide()

func show_restart_icon():
	$RestartIcon.show()

func hide_restart_icon():
	$RestartIcon.hide()
