extends RigidBody2D

func _on_Area2D_body_entered(body):
	if body == self:
		return
	add_collision_exception_with(body)

func _on_Area2D_body_exited(body):
	if body == self:
		return
	remove_collision_exception_with(body)
