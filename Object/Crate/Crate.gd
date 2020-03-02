extends RigidBody2D

var is_grabbed := false
var teleport_position = null
onready var shapes = [
	$CollisionShape2D,
	$CollisionShape2D2,
	$Solid/Shape,
	$CollisionShape2D3
]

onready var node_gfx := $Gfx

func _ready():
	custom_integrator = true
	$Solid.add_collision_exception_with(self)

func _integrate_forces(state: Physics2DDirectBodyState):
	if teleport_position != null:
		state.transform.origin = teleport_position
		teleport_position = null
		node_gfx.position = Vector2.ZERO
	if is_grabbed:
		state.linear_velocity = Vector2.ZERO
	state.integrate_forces()

func grab_begin():
	is_grabbed = true
	for shape in shapes:
		shape.disabled = true
	gravity_scale = 0.0

func grab_end():
	is_grabbed = false
	for shape in shapes:
		shape.disabled = false
	gravity_scale = 1.0

func teleport_to(pos: Vector2, move_with_camera: bool):
	teleport_position = pos
	if move_with_camera:
		node_gfx.global_position = teleport_position

func _physics_process(delta):
	node_gfx.global_position = global_position.round()
