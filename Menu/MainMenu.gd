extends Control

onready var files := [
	$Center/Saves/File1,
	$Center/Saves/File2,
	$Center/Saves/File3
]

var selected_file := 0 setget set_selected_file

func set_selected_file(f: int):
	selected_file = f
	node_sprite.global_position = files[f].rect_global_position

onready var node_sprite := $Sprite

func _ready():
	self.selected_file = 0

func _input(event):
	if event.is_action_pressed("move_down"):
		self.selected_file = posmod(self.selected_file + 1, files.size())
	elif event.is_action_pressed("move_up"):
		self.selected_file = posmod(self.selected_file - 1, files.size())
	elif event.is_action_pressed("action_jump"):
		files[self.selected_file].select()
	elif event.is_action_pressed("action_grab"):
		files[self.selected_file].delete()
