extends Node2D

export var level_id := 0

func _ready():
	if get_tree().current_scene.has_collected_film(level_id):
		modulate = Color(1.0, 1.0, 1.0, 0.5)

func _on_Area2D_body_entered(_body):
	get_tree().current_scene.collect_film(level_id)
	queue_free()
