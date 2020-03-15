extends Control

export var input_name := ""

onready var node_label := $Label
onready var node_btn := $Button
var previous_input
var pressed := false

const PREFIX := "        "

func get_cursor_position():
	return node_btn.rect_global_position

func _ready():
	update_self()
	node_label.text = GameConfig.get_action_name(input_name)
	previous_input = GameConfig.get_keybind(input_name)
	$TextureRect.texture = GameConfig.get_action_icon(input_name)
	yield(get_tree(), "idle_frame")
	$TextureRect.update()
	
func update_self():
	var action = GameConfig.get_keybind(input_name)
	var text = GameConfig.get_event_name(action)
	node_btn.text = PREFIX + text

func update_config(event):
	previous_input = previous_input
	GameConfig.set_keybind(input_name, event)
	$TextureRect.texture = GameConfig.get_action_icon(input_name)
	yield(get_tree(), "idle_frame")
	$TextureRect.update()
#
func _physics_process(_delta):
	node_btn.disabled = pressed

func _input(event):
	if pressed:
		var e = GameConfig.check_input_valid(event)
		if e != null:
			update_config(e)
			update_self()
			pressed = false
			node_btn.accept_event()

func select():
	node_btn.grab_focus()

func unselect():
	node_btn.release_focus()

func activate():
	if not pressed:
		pressed = true
		node_btn.text = PREFIX + "..."

func _on_Button_pressed():
	node_btn.text = PREFIX + "..."
	pressed = true
