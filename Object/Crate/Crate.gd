extends RigidBody2D

var is_grabbed := false
var teleport_position = null

func _ready():
	custom_integrator = true

func _integrate_forces(state: Physics2DDirectBodyState):
	if teleport_position != null:
		state.transform.origin = teleport_position
		teleport_position = null
		$Polygon2D.position = Vector2.ZERO
	if is_grabbed:
		state.linear_velocity = Vector2.ZERO
	state.integrate_forces()

func grab_begin():
	is_grabbed = true
	$CollisionShape2D.disabled = true
	gravity_scale = 0.0

func grab_end():
	is_grabbed = false
	$CollisionShape2D.disabled = false
	gravity_scale = 1.0

func teleport_to(pos: Vector2, move_with_camera: bool):
	teleport_position = pos
	if move_with_camera:
		$Polygon2D.global_position = teleport_position
