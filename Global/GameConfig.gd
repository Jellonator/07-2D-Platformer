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

# Graphical icon stuff
const input_icons := preload("res://Global/InputIcons.png")
const font_mini := preload("res://Ext/KenneyFont/Fonts/minisquare.tres")
const font_color := Color(58.0/256.0, 68.0/256.0, 102.0/256.0, 1.0)

# A bunch of positions that correspond to an atlas position in input_icons
const pos_unknown := Vector2(7, 7)
const pos_ctrl_btn_up := Vector2(0, 0)
const pos_ctrl_btn_left := Vector2(1, 0)
const pos_ctrl_btn_down := Vector2(2, 0)
const pos_ctrl_btn_right := Vector2(3, 0)
const pos_ctrl_stick_up := Vector2(4, 0)
const pos_ctrl_stick_left := Vector2(5, 0)
const pos_ctrl_stick_down := Vector2(6, 0)
const pos_ctrl_stick_right := Vector2(7, 0)
const pos_ctrl_pad_up := Vector2(0, 3)
const pos_ctrl_pad_left := Vector2(1, 3)
const pos_ctrl_pad_down := Vector2(2, 3)
const pos_ctrl_pad_right := Vector2(3, 3)
const pos_ctrl_select := Vector2(4, 3)
const pos_ctrl_start := Vector2(5, 3)
const pos_ctrl_stick_press := Vector2(6, 3)
const pos_ctrl_l1 := Vector2(0, 5)
const pos_ctrl_l2 := Vector2(1, 5)
const pos_ctrl_r1 := Vector2(2, 5)
const pos_ctrl_r2 := Vector2(3, 5)
const pos_key_blank := Vector2(0, 1)
const pos_key_space := Vector2(1, 1)
const pos_key_up := Vector2(2, 1)
const pos_key_left := Vector2(3, 1)
const pos_key_down := Vector2(4, 1)
const pos_key_right := Vector2(5, 1)
const pos_key_shift := Vector2(6, 1)
const pos_key_esc := Vector2(7, 1)
const pos_key_ctrl := Vector2(0, 2)
const pos_key_alt := Vector2(1, 2)
const pos_key_enter := Vector2(2, 2)
const pos_key_f := Vector2(3, 2)
const pos_key_unknown := Vector2(7, 2)
const pos_mouse_left := Vector2(0, 4)
const pos_mouse_middle := Vector2(1, 4)
const pos_mouse_right := Vector2(2, 4)
const pos_mouse_x1 := Vector2(4, 4)
const pos_mouse_x2 := Vector2(5, 4)
const pos_mouse_wheel_up := Vector2(6, 4)
const pos_mouse_wheel_down := Vector2(7, 4)
const pos_mouse_unknown := Vector2(3, 4)

# Unfortunately, you can not draw a font directly to a texture. Instead, you
# have to create a viewport, a canvas, and a canvas item, draw the font to the
# canvas item, then get the texture of the viewport. Since the drawing process
# isn't immediate, you have to yield until the scene has been drawn.
# This also means that the texture will be blank for a frame until it is
# updated.
func _process_image(tex: ImageTexture, img: Image, s: String):
	# Create the scene
	var item := VisualServer.canvas_item_create()
	var view := VisualServer.viewport_create()
	var canvas := VisualServer.canvas_create()
	VisualServer.viewport_attach_canvas(view, canvas)
	VisualServer.canvas_item_set_parent(item, canvas)
	# Configure the viewport
	VisualServer.viewport_set_size(view, 16, 16)
	VisualServer.viewport_set_active(view, true)
	VisualServer.viewport_set_transparent_background(view, true)
	VisualServer.viewport_set_vflip(view, true)
	# Draw the font
	var size := font_mini.get_string_size(s)
	var pos := Vector2((16 - size.x)/2, 8).round()
	font_mini.draw(item, pos, s, font_color)
	# In order for the viewport to update itself, it has to actually be visible
	# in some capacity. The easiest way is to just attatch it to the screen in
	# way so that it's not actually visible.
	VisualServer.viewport_attach_to_screen(view, Rect2(-1, -1, 1, 1))
	# Yield until it draws
	yield(VisualServer, "frame_post_draw")
	# Get the texture
	var viewtex = VisualServer.viewport_get_texture(view)
	var viewtexdata = VisualServer.texture_get_data(viewtex)
	# Convert the texture so that it can be blended
	viewtexdata.convert(img.get_format())
	# Blend the texture onto the image
	img.blend_rect(viewtexdata, Rect2(0, 0, 16, 16), Vector2.ZERO)
	# Copy the image to the texture
	tex.create_from_image(img, 0)
	# Free the scene
	VisualServer.free_rid(item)
	VisualServer.free_rid(view)
	VisualServer.free_rid(canvas)

# Get an icon that matches the given input
# This function is basically a bunch of if statements
# I know the string comparisons look clunky but it just works
# https://i.imgur.com/zmRKd9m.png
func get_event_icon(event: InputEvent) -> Texture:
	var pos := pos_unknown
	var tex := AtlasTexture.new()
	tex.atlas = input_icons
	if event is InputEventKey:
		var ek := event as InputEventKey
		match ek.scancode:
			KEY_SPACE: pos = pos_key_space
			KEY_UP: pos = pos_key_up
			KEY_LEFT: pos = pos_key_left
			KEY_DOWN: pos = pos_key_down
			KEY_RIGHT: pos = pos_key_right
			KEY_SHIFT: pos = pos_key_shift
			KEY_ESCAPE: pos = pos_key_esc
			KEY_CONTROL: pos = pos_key_ctrl
			KEY_ALT: pos = pos_key_alt
			KEY_ENTER: pos = pos_key_enter
			_:
				# Handle other keys. This will generate text for both function
				# keys and single-character keys.
				var code := OS.get_scancode_string(ek.scancode)
				if code.length() > 2 and ek.unicode != 0:
					code = char(ek.unicode)
				if code.length() == 2 and code.begins_with("F") or code.length() == 1:
					# Determine rect
					pos = Vector2(0, 1)
					var rect := Rect2(pos.x*16, pos.y*16, 16, 16)
					# Get image
					var img := input_icons.get_data().get_rect(rect)
					# Create the texture with an empty base
					var newtex := ImageTexture.new()
					newtex.create_from_image(img, 0)
					# Send it to be processed (this function will yield)
					_process_image(newtex, img, code)
					# Return the image (it will be updated next frame)
					return newtex
				pos = pos_key_unknown
	if event is InputEventMouseButton:
		var emb := event as InputEventMouseButton
		if emb.button_index == BUTTON_LEFT:
			pos = pos_mouse_left
		elif emb.button_index == BUTTON_RIGHT:
			pos = pos_mouse_right
		elif emb.button_index == BUTTON_MIDDLE:
			pos = pos_mouse_middle
		elif emb.button_index == BUTTON_WHEEL_DOWN:
			pos = pos_mouse_wheel_down
		elif emb.button_index == BUTTON_WHEEL_UP:
			pos = pos_mouse_wheel_up
		elif emb.button_index == BUTTON_WHEEL_LEFT:
			pos = pos_mouse_unknown
		elif emb.button_index == BUTTON_WHEEL_RIGHT:
			pos = pos_mouse_unknown
		else:
			if emb.button_index % 2 == 1:
				pos = pos_mouse_x1
			else:
				pos = pos_mouse_x2
	if event is InputEventJoypadButton:
		var name = get_event_name(event)
		if name == "Face Button Top":
			pos = pos_ctrl_btn_up
		if name == "Face Button Left":
			pos = pos_ctrl_btn_left
		if name == "Face Button Bottom":
			pos = pos_ctrl_btn_down
		if name == "Face Button Right":
			pos = pos_ctrl_btn_right
		if name == "DPAD Up":
			pos = pos_ctrl_pad_up
		if name == "DPAD Left":
			pos = pos_ctrl_pad_left
		if name == "DPAD Down":
			pos = pos_ctrl_pad_down
		if name == "DPAD Right":
			pos = pos_ctrl_pad_right
		if name == "L":
			pos = pos_ctrl_l1
		if name == "L2":
			pos = pos_ctrl_l2
		if name == "R":
			pos = pos_ctrl_r1
		if name == "R2":
			pos = pos_ctrl_r2
		if name == "L3":
			pos = pos_ctrl_stick_press
		if name == "R3":
			pos = pos_ctrl_stick_press
		if name == "Start":
			pos = pos_ctrl_start
		if name == "Select":
			pos = pos_ctrl_select
	if event is InputEventJoypadMotion:
		var name = get_event_name(event)
		if name == "+L":
			pos = pos_ctrl_l1
		if name == "+L2":
			pos = pos_ctrl_l2
		if name == "+R":
			pos = pos_ctrl_r1
		if name == "+R2":
			pos = pos_ctrl_r2
		if name == "+Left Stick X":
			pos = pos_ctrl_stick_right
		if name == "-Left Stick X":
			pos = pos_ctrl_stick_left
		if name == "+Left Stick Y":
			pos = pos_ctrl_stick_down
		if name == "-Left Stick Y":
			pos = pos_ctrl_stick_up
		if name == "+Right Stick X":
			pos = pos_ctrl_stick_right
		if name == "-Right Stick X":
			pos = pos_ctrl_stick_left
		if name == "+Right Stick Y":
			pos = pos_ctrl_stick_down
		if name == "-Right Stick Y":
			pos = pos_ctrl_stick_up
	tex.region = Rect2(pos.x*16, pos.y*16, 16, 16)
	return tex
