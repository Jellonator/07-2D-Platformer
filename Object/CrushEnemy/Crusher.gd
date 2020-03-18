extends KinematicBody2D

var num_camera := 0
var num_player := 0
onready var original_position := position
var is_crushing := false
var velocity := Vector2.ZERO
var wait := 0.0
const MAX_VELOCITY := 320.0
var crush_time := 0.0
var rattle_time := 0.0

func _physics_process(delta: float):
	if wait > 0.0:
		wait -= delta
		$BoxCrush/Shape.disabled = true
		return
	if is_crushing:
		crush_time += delta
		if crush_time < 1.0:
			rattle_time -= delta
			var off := $Sprite.offset as Vector2
			var x1 := clamp(off.x-0.5, -1, 1)
			var x2 := clamp(off.x+0.5, -1, 1)
			var y1 = clamp(off.y-0.5, -1, 1)
			var y2 = clamp(off.y+0.5, -1, 1)
			$Sprite.offset.x = rand_range(x1, x2)
			$Sprite.offset.y = rand_range(y1, y2)
			velocity.y = clamp(velocity.y + delta * 5.0, 0.0, MAX_VELOCITY)
		else:
			$Sprite.offset = Vector2.ZERO
			velocity.y = clamp(velocity.y + delta * 640.0, 0.0, MAX_VELOCITY)
		$BoxCrush/Shape.disabled = false
		var col := move_and_collide(velocity * delta, false, true, false)
		if col != null:
			is_crushing = false
			wait = 2.0
	else:
		$Sprite.offset = Vector2.ZERO
		$BoxCrush/Shape.disabled = true
		velocity = Vector2.ZERO
		var diff := original_position - position
		var speed := 60.0 * delta
		var move := Vector2.ZERO
		if diff.length() <= speed:
			move = diff
			if num_camera > 0 and num_player > 0:
				is_crushing = true
				crush_time = 0.0
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
