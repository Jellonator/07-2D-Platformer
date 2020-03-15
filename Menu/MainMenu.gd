extends Control

onready var files := [
	$Center/Saves/File1,
	$Center/Saves/File2,
	$Center/Saves/File3,
	$Center/Saves/Options
]

var selected_file := 0 setget set_selected_file

func set_selected_file(f: int):
	selected_file = f
	node_sprite.global_position = files[f].rect_global_position

onready var node_sprite := $Sprite

func _ready():
	self.selected_file = 0
# warning-ignore:return_value_discarded
	GameConfig.connect("icon_changed", self, "on_input_changed")
	on_input_changed("action_grab")
	on_input_changed("action_jump")
	files[selected_file].select()

func on_input_changed(name: String):
	match name:
		"action_grab":
			$BtnDelete.texture = GameConfig.get_action_icon("action_grab")
		"action_jump":
			$BtnCreate.texture = GameConfig.get_action_icon("action_jump")

func _input(event):
	if event.is_action_pressed("move_down"):
		files[selected_file].unselect()
		self.selected_file = posmod(self.selected_file + 1, files.size())
		files[selected_file].select()
	elif event.is_action_pressed("move_up"):
		files[selected_file].unselect()
		self.selected_file = posmod(self.selected_file - 1, files.size())
		files[selected_file].select()
	elif event.is_action_pressed("action_jump"):
		files[self.selected_file].activate()
	elif event.is_action_pressed("action_grab"):
		files[self.selected_file].delete()
