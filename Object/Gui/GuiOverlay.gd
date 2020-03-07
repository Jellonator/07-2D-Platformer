extends CanvasLayer

var films := {}
var scene_film := preload("res://Object/Gui/Film.tscn")
onready var node_films := $Films

var show_film_timer := 0.0

func _ready():
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
	if show_film_timer > 0.0:
		node_films.rect_position.y = clamp(node_films.rect_position.y + delta * 64.0, -16.0, 0.0)
	else:
		node_films.rect_position.y = clamp(node_films.rect_position.y - delta * 64.0, -16.0, 0.0)
