extends Node

# Jello's cool user configuration script. Be sure to add this as a global
# Autoload script in the project settings!
# How to configure:
#     * Add all of the inputs you want the user to be able to configure to
#     SECTION_KEY_ELEMENTS. The keys in this dictionary are the names of the
#     inputs as defined in the Input Map in project settings, and the values
#     are the user-readable names.
#     * Add all of the volumes you want the user to be able to configure to
#     SECTION_VOLUME_ELEMENTS. The values in this array are the bus names.
#     * Add all of the miscellaneous configuration elements to CONFIG. The keys
#     in this dictionary are the names of the elements, and the values are the
#     default values for these elements.
# By default, the configuration is stored in user://configuration.cfg. You can
# Chance this to a different file by modifying CONFIG_FILE.
# The config file will be automatically loaded when this script is autoloaded.

# Path to the user's configuration file
const CONFIG_FILE := "user://configuration.cfg"
# Handle to the user's configuration file
onready var config := ConfigFile.new();

# Section name for the player's keybinds
const SECTION_KEYS := "keybinds"
# Section name for the player's volume
const SECTION_VOLUME := "volume"
# Section for game config
const SECTION_CONFIG := "config"
# All configurable keys
const SECTION_KEY_ELEMENTS := {
	"move_up": "Move Up",
	"move_down": "Move Down",
	"move_left": "Move Left",
	"move_right": "Move Right",
	"action_jump": "Jump",
	"action_grab": "Grab",
	"action_restart": "Restart",
	"action_pause": "Pause"
}
# All configurable volumes
const SECTION_VOLUME_ELEMENTS := [
	"Sound",
	"Music",
	"Master",
]

# CONFIG VALUES
var CONFIG := {
}

# Get the real name for a given action
func get_action_name(name: String) -> String:
	if SECTION_KEY_ELEMENTS.has(name):
		return SECTION_KEY_ELEMENTS[name]
	return "Invalid"

# Get the volume for the given volume name
func get_volume(name: String) -> float:
	return config.get_value(SECTION_VOLUME, name);

# Get the volume from 1 - 100
func get_volume_slider(name: String) -> float:
	return get_volume(name) * 100
	
# Updates the volume of the given bus to the given value
func _update_volume(name: String):
	var volumedb := linear2db(get_volume(name))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(name), volumedb)

# Set the volume for the given volume name
func set_volume(name: String, value: float):
	config.set_value(SECTION_VOLUME, name, value);
	_update_volume(name)
# warning-ignore:return_value_discarded
	_save_config();

# Set the volume but from 1 - 100
func set_volume_slider(name: String, value: float):
	set_volume(name, value/100)

# Used to make sure config has all of the necessary settings
func _check_config():
	var does_need_save := false
	for name in SECTION_KEY_ELEMENTS.keys():
		if not config.has_section_key(SECTION_KEYS, name):
			config.set_value(SECTION_KEYS, name, InputMap.get_action_list(name)[0]);
			does_need_save = true
	for name in SECTION_VOLUME_ELEMENTS:
		if not config.has_section_key(SECTION_VOLUME, name):
			config.set_value(SECTION_VOLUME, name, 0.5);
			does_need_save = true
	for name in CONFIG:
		if not config.has_section_key(SECTION_CONFIG, name):
			if not config.has_section_key(SECTION_CONFIG, name):
				config.set_value(SECTION_CONFIG, name, CONFIG[name])
				does_need_save = true
	if does_need_save:
# warning-ignore:return_value_discarded
		_save_config()

func _ready():
	# Make sure that the config file exists
	var file := File.new();
	if not file.file_exists(CONFIG_FILE):
# warning-ignore:return_value_discarded
		file.open(CONFIG_FILE, file.WRITE)
		file.close();
# warning-ignore:return_value_discarded
		_save_config();
# warning-ignore:return_value_discarded
	_load_config();

# Update all events in map to match settings
func _update_events():
	for name in SECTION_KEY_ELEMENTS.keys():
		var events = config.get_value(SECTION_KEYS, name);
		InputMap.action_erase_events(name)
		if typeof(events) == TYPE_ARRAY:
			for event in events:
				InputMap.action_add_event(name, event);
		else:
			InputMap.action_add_event(name, events);

# Converts the given volume to DB.
func _update_volumes():
	for name in SECTION_VOLUME_ELEMENTS:
		_update_volume(name)

# Load configuration
func _load_config() -> int:
	var err := config.load(CONFIG_FILE);
	if err != OK:
		printerr("Error loading user configuration: ", err);
	# After loading, check configuration
	# to make sure it is valid
	_check_config();
	# And update InputMap to match
	_update_events();
	# Also update volume
	_update_volumes();
	# Update config
	for key in CONFIG:
		if config.has_section_key(SECTION_CONFIG, key):
			CONFIG[key] = config.get_value(SECTION_CONFIG, key)
	return err

# Save configuration to file
func _save_config() -> int:
	var err := config.save(CONFIG_FILE);
	if err != OK:
		printerr("Error saving user configuration: ", err);
	return err

# Get a keybind
func get_keybind(name: String):
	return config.get_value(SECTION_KEYS, name)

# Set a keybind to a given event
func set_keybind(name: String, event: InputEvent):
	config.set_value(SECTION_KEYS, name, event)
# warning-ignore:return_value_discarded
	_save_config()
	InputMap.action_erase_events(name)
	InputMap.action_add_event(name, event);

# Set the value of a configuration variable.
func set_config_value(name: String, value):
	if name in CONFIG:
		if typeof(CONFIG[name]) == typeof(value):
			CONFIG[name] = value
			config.set_value(SECTION_CONFIG, name, value)
# warning-ignore:return_value_discarded
			_save_config()
			return OK
		else:
			return ERR_INVALID_DATA
	else:
		return ERR_DOES_NOT_EXIST

# Get the value of a configuration variable.
func get_config_value(name: String):
	return CONFIG[name]

# Check if an event is really a valid event
# Returns null if not valid, returns event if is valid
func check_input_valid(event: InputEvent):
	if event is InputEventKey:
		var ek := event as InputEventKey
		if ek.pressed and not ek.echo:
			ek.control = false
			ek.shift = false
			ek.meta = false
			ek.alt = false
			ek.command = false
			return ek
	if event is InputEventMouseButton:
		var emb := event as InputEventMouseButton
		if emb.pressed and not emb.doubleclick:
			emb.control = false
			emb.shift = false
			emb.meta = false
			emb.alt = false
			emb.command = false
			return emb
	if event is InputEventJoypadButton:
		var ejb := event as InputEventJoypadButton
		if ejb.pressed:
			return ejb
	if event is InputEventJoypadMotion:
		var ejm := event as InputEventJoypadMotion
		ejm.axis_value = 0.1 * sign(ejm.axis_value)
		return ejm
	return null

# Get name of an event
func get_event_name(event: InputEvent) -> String:
	if event is InputEventKey:
		var ek := event as InputEventKey
		return OS.get_scancode_string(ek.scancode)
	if event is InputEventMouseButton:
		var emb := event as InputEventMouseButton
		if emb.button_index == BUTTON_LEFT:
			return "Left click"
		elif emb.button_index == BUTTON_RIGHT:
			return "Right click"
		elif emb.button_index == BUTTON_MIDDLE:
			return "Middle click"
		elif emb.button_index == BUTTON_WHEEL_DOWN:
			return "Mouse wheel down"
		elif emb.button_index == BUTTON_WHEEL_UP:
			return "Mouse wheel down"
		elif emb.button_index == BUTTON_WHEEL_LEFT:
			return "Mouse wheel left"
		elif emb.button_index == BUTTON_WHEEL_RIGHT:
			return "Mouse wheel right"
		else:
			return "Mouse button " + str(emb.button_index)
	if event is InputEventJoypadButton:
		var ejb := event as InputEventJoypadButton
		return Input.get_joy_button_string(ejb.button_index)
	if event is InputEventJoypadMotion:
		var ejm := event as InputEventJoypadMotion
		if ejm.axis_value < 0:
			return "-" + Input.get_joy_axis_string(ejm.axis)
		else:
			return "+" + Input.get_joy_axis_string(ejm.axis)
	return "Invalid"
