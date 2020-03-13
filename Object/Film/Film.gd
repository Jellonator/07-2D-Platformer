extends Node2D

export var level_id := 0
var following = null
var finished = false

func _physics_process(delta):
	if finished:
		return
	if following != null:
		if following.has_camera():
			get_tree().current_scene.collect_film(level_id)
			$AnimationPlayer.play("Anim")
			$PartBack.emitting = false
			$PartFront.emitting = false
			$SndCollect.play()
			finished = true
		else:
			var diff = global_position - following.global_position
			if diff.length() > 16.0:
				var target = following.global_position + diff.normalized() * 16
				diff = target - global_position
				position += diff * delta * 4.0

func _ready():
	$Sprite.material = $Sprite.material.duplicate()
	if get_tree().current_scene.has_collected_film(level_id):
		modulate = Color(1.0, 1.0, 1.0, 0.5)

func _on_Area2D_body_entered(body):
	if following == null:
		following = body
		$SndTouch.play()

func _on_AnimationPlayer_animation_finished(anim_name: String):
	if anim_name == "Anim":
		queue_free()
