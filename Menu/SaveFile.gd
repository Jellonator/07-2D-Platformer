extends Control

export var file_name := ""
export var title := ""

var should_load := true
const KNOWN_FILMS := 10

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

func select():
	if should_load:
		GameData.load_data(file_name)
		var scene = preload("res://Menu/LevelSelect/LevelSelect.tscn")
		var err = get_tree().change_scene_to(scene)
		if err != OK:
			push_error("Could not load level select [{0}]".format(err))
	else:
		$Create.hide()
		$Load.show()
		should_load = true
		GameData.create_data(file_name)
		set_display()

func delete():
	if should_load:
		$Create.show()
		$Load.hide()
		should_load = false
		var dir := Directory.new()
		var err = dir.remove(file_name)
		if err != OK:
			push_error("Could not delete save " + file_name + " [" + str(err) + "]")
