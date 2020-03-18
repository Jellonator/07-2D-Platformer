extends Node2D

const scene_gui := preload("res://Object/Gui/GuiOverlay.tscn")

export var unique_name := ""
export var initial_checkpoint := 1
var node_gui
var is_finished := false
var finish_timer := 0.0
var checkpoints := {}

func add_checkpoint(id: int, node):
	if id in checkpoints:
		print("There are two checkpoints with id %d" % id)
	else:
		checkpoints[id] = node

func _enter_tree():
	if GameData.get_checkpoint() == -1:
		GameData.set_checkpoint(initial_checkpoint)

func _ready():
	node_gui = scene_gui.instance()
	add_child(node_gui)
	if unique_name == "":
		push_warning("Level does not have unique name for storing data")
	var id := GameData.get_checkpoint()
	if id == -1:
		id = initial_checkpoint
	if id in checkpoints:
		checkpoints[id].create()
	else:
		print("No such checkpoint with id %d" % id)

func _physics_process(delta):
	if is_finished:
		var pt = finish_timer
		finish_timer += delta
		if pt < 1.5 and finish_timer >= 1.5:
			get_tree().call_group("player", "begin_walk_anim", 0.8)
		if finish_timer > 4.0:
			var err = get_tree().change_scene("res://Menu/LevelSelect/LevelSelect.tscn")
			if err != OK:
				push_error("Could not load level select [{0}]".format([err]))

func collect_film(id: int):
	node_gui.collect_film(id)
	GameData.collect_film(unique_name, id)
	GameData.try_autosave()

func has_collected_film(id: int) -> bool:
	return GameData.has_collected_film(unique_name, id)

func finish_level():
	if is_finished:
		return
	is_finished = true
	GameData.set_level_completed(unique_name)
	GameData.try_autosave()
	get_tree().call_group("player", "begin_stop")
	get_tree().call_group("camera", "begin_stop")
