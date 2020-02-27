extends KinematicBody2D

const TERMINAL_VELOCITY := 800
const MAX_SPEED := 240.0
const MOVE_ACCEL := 1600.0
const GRAVITY := 800.0
const JUMP_SPEED := 400.0

var velocity := Vector2()

func _physics_process(delta: float):
	velocity += Vector2(0, 1) * delta * GRAVITY
	var move_dir := Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	var target_speed := move_dir * MAX_SPEED
	var accel := MOVE_ACCEL * delta
	print(is_on_floor())
	if abs(velocity.x - target_speed) < accel:
		velocity.x = target_speed
	elif velocity.x < target_speed:
		velocity.x = clamp(velocity.x + accel, -MAX_SPEED, MAX_SPEED)
	else:
		velocity.x = clamp(velocity.x - accel, -MAX_SPEED, MAX_SPEED)
	if is_on_floor():
		velocity = move_and_slide_with_snap(velocity, Vector2(0, 4), Vector2(0, -1))
	else:
		velocity = move_and_slide(velocity, Vector2(0, -1))

func _input(event):
	if event.is_action_pressed("action_jump") and is_on_floor():
		velocity.y = -JUMP_SPEED
