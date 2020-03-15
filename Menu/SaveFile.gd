extends Control

export var file_name := ""
export var title := ""

var should_load := true
const KNOWN_FILMS := 10
onready var pressed := false

onready var move_nodes := [
	$Title,
	$Load/FilmCount,
	$Load/TextureRect,
	$Create/CreateLabel
]

func set_display():
	var cfg = GameData.load_to_config(file_name)
	var num = GameData.config_count_collected_films(cfg)
	$Load/FilmCount.text = "{0}/{1}".format([num, KNOWN_FILMS])

func _ready():
	$Title.text = title
	var fh := File.new()
	if fh.file_exists(file_name):
		should_load = true
		$Create.hide()
		set_display()
	else:
		should_load = false
		$Load.hide()

func do_load_game():
	GameData.load_data(file_name)
	var scene = preload("res://Menu/LevelSelect/LevelSelect.tscn")
	var err = get_tree().change_scene_to(scene)
	if err != OK:
		push_error("Could not load level select [{0}]".format(err))

func activate():
	if should_load:
		do_load_game()
	else:
		GameData.create_data(file_name)
		do_load_game()

func delete():
	if should_load:
		$Create.show()
		$Load.hide()
		should_load = false
		var dir := Directory.new()
		var err = dir.remove(file_name)
		if err != OK:
			push_error("Could not delete save " + file_name + " [" + str(err) + "]")

func select():
	if pressed:
		return
	pressed = true
	$Create/Unpressed.hide()
	$Create/Pressed.show()
	$Load/Unpressed.hide()
	$Load/Pressed.show()
	for node in move_nodes:
		node.rect_position += Vector2(0, 2)

func unselect():
	if not pressed:
		return
	pressed = false
	$Create/Unpressed.show()
	$Create/Pressed.hide()
	$Load/Unpressed.show()
	$Load/Pressed.hide()
	for node in move_nodes:
		node.rect_position -= Vector2(0, 2)
