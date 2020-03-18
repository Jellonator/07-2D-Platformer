extends Node2D

var has_checkpointed := false
var test_body = null

enum CameraMode{HOLDING, ALONGSIDE, NO_CAMERA}

const scene_player := preload("res://Object/Player/Player.tscn")
const scene_camera := preload("res://Object/Camera/Camera.tscn")

export var checkpoint_id: int = 0
export var do_hide := false
export(CameraMode) var camera_mode := CameraMode.HOLDING

func _ready():
	if do_hide:
		hide()
	owner.add_checkpoint(checkpoint_id, self)
	if do_hide or checkpoint_id == GameData.get_checkpoint():
		has_checkpointed = true
		$AnimationPlayer.play("skip")

func do_checkpoint():
	if has_checkpointed:
		return
	has_checkpointed = true
	$AnimationPlayer.play("dothing")
	GameData.set_checkpoint(checkpoint_id)

func _physics_process(_delta):
	if test_body != null and test_body.has_camera():
		do_checkpoint()
		test_body = null

func _on_Area2D_body_entered(body):
	if body.has_camera():
		do_checkpoint()
	else:
		test_body = body

func _on_Area2D_body_exited(body):
	if body == test_body:
		test_body = null

func create():
	var p = scene_player.instance()
	p.position = position + Vector2(0, -8)
	match camera_mode:
		CameraMode.ALONGSIDE:
			get_tree().call_group("camera", "queue_free")
			p.global_position = position + Vector2(-12, -8)
			owner.add_child(p)
			var c = scene_camera.instance()
			c.position = position + Vector2(12, -8)
			owner.add_child(c)
		CameraMode.HOLDING:
			get_tree().call_group("camera", "queue_free")
			owner.add_child(p)
			var c = scene_camera.instance()
			c.position = position + Vector2(12, -8)
			owner.add_child(c)
			p.set_grabbed_object(c)
		CameraMode.NO_CAMERA:
			owner.add_child(p)
