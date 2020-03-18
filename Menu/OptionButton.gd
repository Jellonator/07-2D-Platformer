extends Button
onready var player_pressed := false

func _ready():
	unselect()

func activate():
	if get_parent().is_locked():
		return
	var scene = load("res://Menu/KeyRebind.tscn")
	var err = get_tree().change_scene_to(scene)
	if err != OK:
		push_error("Could not load key rebind [{0}]".format(err))

func delete():
	pass

func select():
	grab_focus()
	if player_pressed:
		return
	player_pressed = true

func unselect():
	release_focus()
	if not player_pressed:
		return
	player_pressed = false

func _on_Options_pressed():
	if get_parent().is_locked():
		return
	activate()
	get_parent().select(get_position_in_parent())

func _physics_process(delta):
	if get_parent().is_locked() and get_parent().current != get_position_in_parent():
		release_focus()
	self.disabled = get_parent().is_locked()
