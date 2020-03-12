extends Area2D

func _on_Area2D_body_entered(body):
	body.show_jump_icon()

func _on_Area2D_body_exited(body):
	body.hide_jump_icon()
