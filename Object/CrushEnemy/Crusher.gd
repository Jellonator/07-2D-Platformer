extends KinematicBody2D

var num_camera := 0
var num_player := 0
onready var original_position := position
var is_crushing := false
var velocity := Vector2.ZERO
var wait := 0.0

func _physics_process(delta: float):
	if wait > 0.0:
		wait -= delta
		$BoxCrush/Shape.disabled = true
		return
	if is_crushing:
		$BoxCrush/Shape.disabled = false
		velocity.y = clamp(velocity.y + delta * 320.0, 0.0, 200.0)
		var col := move_and_collide(velocity * delta, true, true, false)
		if col != null:
			is_crushing = false
			wait = 1.0
	else:
		$BoxCrush/Shape.disabled = true
		velocity = Vector2.ZERO
		var diff := original_position - position
		var speed := 60.0 * delta
		var move := Vector2.ZERO
		if diff.length() <= speed:
			move = diff
			if num_camera > 0 and num_player > 0:
				is_crushing = true
		else:
			move = diff.normalized() * speed
		if move != Vector2.ZERO:
# warning-ignore:return_value_discarded
			move_and_collide(move, true, true, false)

func _on_PlayerKill_body_entered(body):
	if body.has_method("do_kill"):
			body.do_kill()

func _on_BoxCrush_body_entered(body):
	if body.has_method("do_crush"):
		body.do_crush()
		is_crushing = false
		wait = 1.0

func _on_CameraDetect_body_entered(_body):
	num_camera += 1

func _on_CameraDetect_body_exited(_body):
	num_camera -= 1

func _on_PlayerDetect_body_entered(_body):
	num_player += 1

func _on_PlayerDetect_body_exited(_body):
	num_player -= 1
