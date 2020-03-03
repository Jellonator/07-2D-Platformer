extends AnimationPlayer

export var animation_name := "anim"

func _ready():
	play(animation_name)
