extends Control
onready var pressed := false

onready var move_nodes := [
	$Label
]

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
	if pressed:
		return
	pressed = true
	$Unpressed.hide()
	$Pressed.show()
	for node in move_nodes:
		node.rect_position += Vector2(0, 2)

func unselect():
	if not pressed:
		return
	pressed = false
	$Unpressed.show()
	$Pressed.hide()
	for node in move_nodes:
		node.rect_position -= Vector2(0, 2)
