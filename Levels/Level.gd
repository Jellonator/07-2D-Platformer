extends Node2D

const scene_gui := preload("res://Object/Gui/GuiOverlay.tscn")

export var unique_name := ""
var node_gui

func _ready():
	node_gui = scene_gui.instance()
	add_child(node_gui)
	if unique_name == "":
		push_warning("Level does not have unique name for storing data")

func collect_film(id: int):
	node_gui.collect_film(id)
	GameData.collect_film(unique_name, id)
	GameData.try_autosave()

func has_collected_film(id: int) -> bool:
	return GameData.has_collected_film(unique_name, id)

func finish_level():
	GameData.set_level_completed(unique_name)
	var err = get_tree().change_scene("res://Menu/LevelSelect/LevelSelect.tscn")
	if err != OK:
		push_error("Could not load level select [{0}]".format([err]))
