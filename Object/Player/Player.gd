extends KinematicBody2D

const TERMINAL_VELOCITY := 400
const MAX_SPEED := 120.0
const MOVE_ACCEL := 800.0
const GRAVITY := 600.0
const JUMP_SPEED := 260.0
const JUMP_SPEED_GRAB := 220.0

var velocity := Vector2()
var grabbed_object = null
var potential_grabs := []

func _physics_process(delta: float):
#	print(get_floor_velocity())
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
#	move_and_collide(floorveloc * delta)
	velocity += floorveloc
	if is_on_floor():
		velocity = move_and_slide_with_snap(velocity, Vector2(0, 2), Vector2(0, -1), true, 4, 0.785398, false)
	else:
		velocity = move_and_slide(velocity, Vector2(0, -1), true, 4, 0.785398, false)
#	if floorveloc.y < 0:
	velocity -= floorveloc
#		floorveloc.y = 0
#	for i in range(get_slide_count()):
#		print(get_slide_collision(i).collider_velocity)
	if Input.is_action_just_pressed("action_grab"):
		if grabbed_object != null:
			grabbed_object.grab_end()
			if not Input.is_action_pressed("move_down"):
				var dir = ($Flip/DropPosition.global_position - $Flip/GrabPosition.global_position).normalized()
				grabbed_object.apply_impulse(Vector2.ZERO, velocity + dir * 60.0)
			grabbed_object = null
		elif potential_grabs.size() > 0:
			grabbed_object = potential_grabs[0]
			grabbed_object.grab_begin()
			grabbed_object.teleport_to($Flip/GrabPosition.global_position, false)
	elif grabbed_object != null:
		grabbed_object.teleport_to($Flip/GrabPosition.global_position, true)

func _input(event):
	if event.is_action_pressed("action_jump") and is_on_floor():
		if grabbed_object != null:
			velocity.y = -JUMP_SPEED_GRAB
		else:
			velocity.y = -JUMP_SPEED

func _on_GrabArea_body_entered(body):
	potential_grabs.append(body)

func _on_GrabArea_body_exited(body):
	potential_grabs.erase(body)
