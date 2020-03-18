extends Control
onready var pressed := false

func _ready():
	unselect()

func activate():
	var scene = load("res://Menu/KeyRebind.tscn")
	var err = get_tree().change_scene_to(scene)
	if err != OK:
		push_error("Could not load key rebind [{0}]".format(err))

func delete():
	pass

func select():
	grab_focus()
	if pressed:
		return
	pressed = true

func unselect():
	release_focus()
	if not pressed:
		return
	pressed = false

func _on_Options_pressed():
	activate()
	get_parent().select(get_position_in_parent())
