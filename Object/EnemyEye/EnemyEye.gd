extends Node2D

var t := 1.0

const SPEED := 6.0
const REGION_SPEED := 120.0

var num := 0

func _physics_process(delta):
	if num > 0:
		t = clamp(t - delta * SPEED, 0.0, 1.0)
	else:
		t = clamp(t + delta * SPEED, 0.0, 1.0)
	$Eye.frame = int(t * 3)
	if t <= 0.0:
		if not $RayCast2D.enabled:
			$RayCast2D.enabled = true
			$RayCast2D.force_raycast_update()
		$Sprite.frame = 0
		$Sprite.show()
		var region := $Sprite.region_rect as Rect2
		region.position.y = fmod(region.position.y - delta * REGION_SPEED, 16.0)
		var length = $RayCast2D.global_position.distance_to($RayCast2D.get_collision_point())
		region.size.y = length
		$Sprite.region_rect = region
		var obj = $RayCast2D.get_collider()
		if obj != null and obj.has_method("do_kill"):
			obj.do_kill()
	elif t < 1.0:
		if not $RayCast2D.enabled:
			$RayCast2D.enabled = true
			$RayCast2D.force_raycast_update()
		$Sprite.show()
		$Sprite.frame = clamp(int(t*3 + 1), 1, 3)
		var region := $Sprite.region_rect as Rect2
		region.position.y = fmod(region.position.y - delta * REGION_SPEED, 16.0)
		var length = $RayCast2D.global_position.distance_to($RayCast2D.get_collision_point())
		region.size.y = length
		$Sprite.region_rect = region
	else:
		$RayCast2D.enabled = false
		$Sprite.hide()

func _on_Area2D_body_entered(body):
	num += 1

func _on_Area2D_body_exited(body):
	num -= 1
