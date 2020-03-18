extends Node2D

var t := 1.0

const SPEED := 6.0
const REGION_SPEED := 120.0

var num := 0

onready var cast_solid := $SolidCast
onready var cast_all := $AllCast

func update_sprite(delta: float):
	var region := $Sprite.region_rect as Rect2
	region.position.y = fmod(region.position.y - delta * REGION_SPEED, 16.0)
	var length = cast_solid.global_position.distance_to(cast_solid.get_collision_point())
	region.size.y = length
	$Sprite.region_rect = region

func _physics_process(delta: float):
	if num > 0:
		t = clamp(t - delta * SPEED, 0.0, 1.0)
	else:
		t = clamp(t + delta * SPEED, 0.0, 1.0)
	$Eye.frame = int(t * 3)
	if t <= 0.0:
		if not cast_solid.enabled:
			cast_solid.enabled = true
			cast_solid.force_raycast_update()
		if not cast_all.enabled:
			cast_all.enabled = true
			cast_all.force_raycast_update()
		$Sprite.frame = 0
		$Sprite.show()
		update_sprite(delta)
		var obj_solid = cast_solid.get_collider()
		var obj_all = cast_all.get_collider()
		var dis = cast_all.get_collision_point().distance_to(cast_solid.get_collision_point())
#		prints(obj_solid, obj_all, dis, obj_all.has_method("do_kill"))
		if obj_all != null and obj_all.has_method("do_kill"):
			if obj_solid == null or dis > 8.0 or obj_all == obj_solid:
				obj_all.do_kill()
#		var obj = $RayCast2D.get_collider()
#		if obj != null and obj.has_method("do_kill"):
#			var dis = $RayCast2D.get_collision_point().distance_to($RayCast2D.global_position)
#			if dis >= 8.0:
#				obj.do_kill()
	elif t < 1.0:
		if not cast_solid.enabled:
			cast_solid.enabled = true
			cast_solid.force_raycast_update()
		$Sprite.show()
		$Sprite.frame = clamp(int(t*3 + 1), 1, 3)
		update_sprite(delta)
	else:
		cast_solid.enabled = false
		cast_all.enabled = false
		$Sprite.hide()

func _on_Area2D_body_entered(_body):
	num += 1

func _on_Area2D_body_exited(_body):
	num -= 1
