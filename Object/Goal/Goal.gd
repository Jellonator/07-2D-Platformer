extends Node2D

var is_animating := false
onready var node_bird := $Bird
onready var bird_pos: Vector2 = node_bird.position
var velocity := 0.0
var t := 0.0
var wait_body = null

func _physics_process(delta):
	if is_animating:
		velocity = clamp(velocity + delta * 60, 0.0, 120.0)
		var amt := sin(t * 8) * ((120 - velocity) / 60.0 + 4.0)
		node_bird.position.x += velocity * delta
		node_bird.position.y = amt + bird_pos.y
		if cos(t * 8) > 0 and t > 0.08:
			node_bird.frame = 2
		else:
			node_bird.frame = 1
		t += delta * (velocity / 120.0 + 0.26)
	if wait_body and wait_body.has_camera():
		wait_body = null
		do_finish()

func do_finish():
	if is_animating:
		return
	get_tree().current_scene.finish_level()
	is_animating = true

func _on_Area2D_body_entered(body):
	if body.has_camera():
		do_finish()
	else:
		wait_body = body

func _on_Area2D_body_exited(body):
	if body == wait_body:
		wait_body = null
