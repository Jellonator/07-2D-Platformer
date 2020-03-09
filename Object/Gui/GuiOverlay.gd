extends CanvasLayer

var films := {}
var scene_film := preload("res://Object/Gui/Film.tscn")
onready var node_films := $Films

var show_film_timer := 0.0

onready var select_i := 0
onready var selections := [
	$Select/Panel/VBox/Continue,
	$Select/Panel/VBox/Restart,
	$Select/Panel/VBox/Exit
]

onready var node_cursor := $Sprite

func update_selection():
	node_cursor.global_position = selections[select_i].rect_global_position

func _ready():
	$Select.visible = get_tree().paused
	$Sprite.visible = get_tree().paused
	show_film_timer = 1.0
	yield(get_tree(), "idle_frame")
	for film in get_tree().get_nodes_in_group("film"):
		var id = film.level_id
		if id in films:
			print("Two films share the same ID: ", id)
		else:
			var node = scene_film.instance()
			films[id] = node
	var sorted_ids = films.keys()
	sorted_ids.sort()
	for id in sorted_ids:
		$Films/HBox.add_child(films[id])
		if get_parent().has_collected_film(id):
			films[id].collect()

func collect_film(id: int):
	films[id].collect()
	show_film_timer = 1.0

func _physics_process(delta):
	show_film_timer -= delta * 0.25
	if show_film_timer > 0.0 or get_tree().paused:
		node_films.rect_position.y = clamp(node_films.rect_position.y + delta * 64.0, -16.0, 0.0)
	else:
		node_films.rect_position.y = clamp(node_films.rect_position.y - delta * 64.0, -16.0, 0.0)
	if Input.is_action_just_pressed("action_pause"):
		get_tree().paused = not get_tree().paused
		select_i = 0
		$Select.visible = get_tree().paused
		$Sprite.visible = get_tree().paused
		call_deferred("update_selection")
	if get_tree().paused:
		if Input.is_action_just_pressed("move_up"):
			select_i = (select_i - 1) % selections.size()
			update_selection()
		if Input.is_action_just_pressed("move_down"):
			select_i = (select_i + 1) % selections.size()
			update_selection()
		if Input.is_action_just_pressed("action_jump"):
			if select_i == 0:
				get_tree().paused = false
			elif select_i == 1:
				get_tree().paused = false
				restart_level()
				return
			elif select_i == 2:
				get_tree().paused = false
				var err = get_tree().change_scene("res://Menu/LevelSelect/LevelSelect.tscn")
				if err != OK:
					push_error("Could not load level select [{0}]".format([err]))
				return
	if Input.is_action_just_pressed("action_restart"):
		get_tree().paused = false
		restart_level()
		return
	$Select.visible = get_tree().paused
	$Sprite.visible = get_tree().paused

func restart_level():
	var path = get_tree().current_scene.filename
	var err = get_tree().change_scene(path)
	if err != OK:
		push_error("Could not kill >:( (tried to load{0} [{1}])".format([path, err]))
