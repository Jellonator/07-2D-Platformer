extends RigidBody2D

var target: Position2D
var force := Vector2.ZERO

func _integrate_forces(state: Physics2DDirectBodyState):
#	if original_position == null:
#		original_position = state.transform.origin
#	if (original_position - state.transform.origin).length() > 8:
#		state.transform.origin = diff.normalized() * 8 + original_position
	if target != null:
		var diff = state.transform.origin - target.global_position
		if diff.length() > 8:
			state.transform.origin = diff.normalized() * 7.5 + target.global_position
	state.linear_velocity += force
	force = Vector2.ZERO
	state.integrate_forces()

func _ready():
	custom_integrator = true

func pin_to(node):
	$PinJoint2D.node_a = $PinJoint2D.get_path_to(node)

func get_diff() -> Vector2:
	if target != null:
		return global_position - target.global_position
	else:
		return Vector2.ZERO
