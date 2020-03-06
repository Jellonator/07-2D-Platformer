extends Node2D

export var unique_name := ""
onready var node_gui := $GuiOverlay

func _ready():
	if unique_name == "":
		push_warning("Level does not have unique name for storing data")

func collect_film(id: int):
	node_gui.collect_film(id)
