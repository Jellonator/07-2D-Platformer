tool
extends Node2D

export var group = "button"
var num := 0

func begin_press():
	get_tree().call_group(group, "do_press")
#	$Polygon2D2.scale.y = 0.5
	$Sprite.frame = 1

func end_press():
	get_tree().call_group(group, "do_release")
#	$Polygon2D2.scale.y = 1.0
	$Sprite.frame = 0

func _on_Area2D_body_entered(_body):
	num += 1
	if num == 1:
		begin_press()

func _on_Area2D_body_exited(_body):
	num -= 1
	if num == 0:
		end_press()

func _ready():
	if Engine.editor_hint:
		set_physics_process(true)

func _physics_process(_delta):
	if Engine.editor_hint:
		update()

func _draw():
	if Engine.editor_hint:
		for node in get_tree().get_nodes_in_group(group):
			var gpos = node.global_position
			var newpos = global_transform.xform_inv(gpos)
			draw_line(Vector2.ZERO, newpos, Color.red)
