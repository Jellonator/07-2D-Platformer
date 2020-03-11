extends Node

const SECTION_FILMS := "FILM"
const SECTION_OVERWORLD := "OVERWORLD"
const SECTION_LEVEL_COMPLETED := "COMPLETED"

const OVERWORLD_POSITION := "POSITION"

var config: ConfigFile
var file_path := ""

###### EXTERNAL CONFIG FUNCTIONS ######
func load_to_config(fname: String) -> ConfigFile:
	var cfg := ConfigFile.new()
	var err = cfg.load(fname)
	if err != OK:
		push_error("Could not load data from " + fname + " [" + str(err) + "]")
	return cfg

func config_count_collected_films(cfg: ConfigFile) -> int:
	if not cfg.has_section(SECTION_FILMS):
		return 0
	var count := 0
	for level_name in cfg.get_section_keys(SECTION_FILMS):
		count += cfg.get_value(SECTION_FILMS, level_name).size()
	return count

func count_collected_films() -> int:
	return config_count_collected_films(config)

func config_count_collected_films_in_level(cfg: ConfigFile, lname: String) -> int:
	if not cfg.has_section(SECTION_FILMS):
		return 0
	return cfg.get_value(SECTION_FILMS, lname, {}).size()

func count_collected_films_in_level(lname: String) -> int:
	return config_count_collected_films_in_level(config, lname)

###### FILE MANAGEMENT FUNCTIONS ######
func _ready():
	reset_all_data()

func try_autosave():
	if file_path != "":
		save_data(file_path)

func reset_all_data():
	file_path = ""
	config = ConfigFile.new()

func create_data(fname: String):
	reset_all_data()
	file_path = fname
	save_data(fname)

func load_data(fname: String):
	reset_all_data()
	file_path = fname
	var err = config.load(fname)
	if err != OK:
		push_error("Could not load data from " + fname + " [" + str(err) + "]")
	return err

func save_data(fname: String):
	print("Saving to ", fname)
	var err = config.save(fname)
	if err != OK:
		push_error("Could not save data to " + fname + " [" + str(err) + "]")
	return err

###### LOCAL CONFIG FUNCTIONS ######
func has_collected_film(level_name: String, film_id: int) -> bool:
	if not config.has_section(SECTION_FILMS):
		return false
	if config.has_section_key(SECTION_FILMS, level_name):
		return config.get_value(SECTION_FILMS, level_name).has(film_id)
	else:
		return false

func collect_film(level_name: String, film_id: int):
	if not config.has_section_key(SECTION_FILMS, level_name):
		config.set_value(SECTION_FILMS, level_name, {})
	config.get_value(SECTION_FILMS, level_name)[film_id] = true
	print(config.get_value(SECTION_FILMS, level_name))

# May return null
func get_overworld_position():
	if not config.has_section_key(SECTION_OVERWORLD, OVERWORLD_POSITION):
		return null
	return config.get_value(SECTION_OVERWORLD, OVERWORLD_POSITION, null)

func set_overworld_position(pos: Vector2):
	config.set_value(SECTION_OVERWORLD, OVERWORLD_POSITION, pos)

func is_level_completed(levelname: String):
	if not config.has_section_key(SECTION_LEVEL_COMPLETED, levelname):
		return false
	return config.get_value(SECTION_LEVEL_COMPLETED, levelname)

func set_level_completed(levelname: String):
	config.set_value(SECTION_LEVEL_COMPLETED, levelname, true)
