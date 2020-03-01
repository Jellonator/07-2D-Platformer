extends KinematicBody2D

const TERMINAL_VELOCITY := 800
const MAX_SPEED := 240.0
const MOVE_ACCEL := 1600.0
const GRAVITY := 800.0
const JUMP_SPEED := 400.0
const JUMP_SPEED_GRAB := 350.0

var velocity := Vector2()
var grabbed_object = null
var potential_grabs := []
var num_objects_in_drop_area := 0

func can_drop() -> bool:
	return num_objects_in_drop_area == 0

func _physics_process(delta: float):
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
	if is_on_floor():
		velocity = move_and_slide_with_snap(velocity, Vector2(0, 4), Vector2(0, -1), true, 4, 0.785398, false)
	else:
		velocity = move_and_slide(velocity, Vector2(0, -1), true, 4, 0.785398, false)
	if Input.is_action_just_pressed("action_grab"):
		if grabbed_object != null:
			if can_drop():
				grabbed_object.grab_end()
				grabbed_object.teleport_to($Flip/DropPosition.global_position, false)
				grabbed_object.apply_impulse(Vector2.ZERO, velocity)
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

func _on_DropArea_body_entered(body):
	num_objects_in_drop_area += 1

func _on_DropArea_body_exited(body):
	num_objects_in_drop_area -= 1
