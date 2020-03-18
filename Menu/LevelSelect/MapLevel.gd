tool
extends Node2D

export var grid_position_x := 0 setget set_grid_position_x
export var grid_position_y := 0 setget set_grid_position_y

var ignore_tx := false

# This is kinda precarious but I don't think there's a better way
export(String) var real_name := ""
export(String, FILE, "*.tscn") var level_path
export(String) var level_name := ""
export(int) var num_films := 0
export(int, FLAGS, "Up", "Right", "Down", "Left") var block_directions := 0

func can_move_direction(dir: Vector2):
	if GameData.is_level_completed(level_name):
		return true
	elif dir == Vector2.UP and block_directions & 1 > 0:
		return false
	elif dir == Vector2.RIGHT and block_directions & 2 > 0:
		return false
	elif dir == Vector2.DOWN and block_directions & 4 > 0:
		return false
	elif dir == Vector2.LEFT and block_directions & 8 > 0:
		return false
	else:
		return true

func _ready():
	if Engine.editor_hint:
		set_notify_transform(true)
	else:
		if GameData.is_level_completed(level_name):
			var num = GameData.count_collected_films_in_level(level_name)
			if num >= num_films:
				$Sprite.frame = 0
			else:
				$Sprite.frame = 2
		else:
			$Sprite.frame = 1

func _notification(what):
	if what == NOTIFICATION_TRANSFORM_CHANGED and not ignore_tx:
		grid_position_x = int(global_position.x / 16)
		grid_position_y = int(global_position.y / 16)
		update_position()

func update_position():
	ignore_tx = true
	self.global_position = Vector2(grid_position_x, grid_position_y) * 16
	ignore_tx = false

func set_grid_position_x(value: int):
	grid_position_x = value
	update_position()

func set_grid_position_y(value: int):
	grid_position_y = value
	update_position()

func get_level_title() -> String:
	return real_name

func get_film_text() -> String:
	var num = GameData.count_collected_films_in_level(level_name)
	return "{0}/{1}".format([num, num_films])

func activate():
	GameData.clear_checkpoint()
	var err = get_tree().change_scene(level_path)
	if err != OK:
		push_error("Could not load level: \"{0}\" [{1}]".format(level_path, err))
