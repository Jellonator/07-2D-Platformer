extends Node

const SECTION_FILMS := "FILM"

var config: ConfigFile

func _ready():
	reset_all_data()
	var fh := File.new()
	if fh.file_exists("user://save.data"):
		load_data("user://save.data")

func reset_all_data():
	config = ConfigFile.new()

func load_data(fname: String):
	reset_all_data()
	var err = config.load(fname)
	print(config.get_section_keys(SECTION_FILMS))
	if err != OK:
		push_error("Could not load data from " + fname + " [" + str(err) + "]")
	return err

func save_data(fname: String):
	var err = config.save(fname)
	if err != OK:
		push_error("Could not save data to " + fname + " [" + str(err) + "]")
	return err

func _get_film_key(level_name: String, film_id: int) -> String:
	return "{0}_{1}".format([level_name, film_id])

func has_collected_film(level_name: String, film_id: int) -> bool:
	var key := _get_film_key(level_name, film_id)
	return config.get_value(SECTION_FILMS, key, false)

func collect_film(level_name: String, film_id: int):
	var key := _get_film_key(level_name, film_id)
	config.set_value(SECTION_FILMS, key, true)
	save_data("user://save.data")
