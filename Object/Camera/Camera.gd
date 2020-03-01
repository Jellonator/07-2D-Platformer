extends RigidBody2D

const TERMINAL_VELOCITY := 800

onready var node_camera := $Node/Camera2D
onready var node_gfx := $Polygon2D
# true if currently grabbed
var is_grabbed := false
# The position to teleport to. 'null' if there is no teleportation
var teleport_position = null
# Have to store the global position in a separate variable because apparently
# accessing the global position outside of _integrate_forces is bad and buggy
onready var gpos := self.global_position

func _ready():
	node_camera.global_position = global_position
	custom_integrator = true

func _integrate_forces(state: Physics2DDirectBodyState):
	if teleport_position != null:
		state.transform.origin = teleport_position
		teleport_position = null
		node_gfx.position = Vector2.ZERO
	state.integrate_forces()
	if is_grabbed:
		state.linear_velocity = Vector2.ZERO
	if state.linear_velocity.y > TERMINAL_VELOCITY:
		state.linear_velocity.y = TERMINAL_VELOCITY
	gpos = state.transform.origin

func grab_begin():
	is_grabbed = true
	$CollisionShape2D.disabled = true
	gravity_scale = 0.0

func grab_end():
	is_grabbed = false
	$CollisionShape2D.disabled = false
	gravity_scale = 1.0

func teleport_to(pos: Vector2, move_with_camera: bool):
	var ogpos = gpos
	if teleport_position != null:
		ogpos = teleport_position
	teleport_position = pos
	if move_with_camera:
		node_camera.global_position += (teleport_position - ogpos)
		node_gfx.global_position = teleport_position

func _physics_process(delta):
	var target_position = gpos
	var diff = target_position - node_camera.position
	var speed = (10.0 + diff.length() * 10.0) * delta
	if diff.length() < speed:
		node_camera.position = target_position
	else:
		node_camera.position += diff.normalized() * speed
