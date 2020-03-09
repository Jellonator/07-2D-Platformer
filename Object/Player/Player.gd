extends KinematicBody2D

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

func set_hbox_ground(on_ground: bool):
	$Air.disabled = on_ground
	$Ray1.disabled = not on_ground
	$Ray2.disabled = not on_ground
#	$CollisionPolygon2D.disabled = not on_ground

func _ready():
	set_hbox_ground(true)

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
