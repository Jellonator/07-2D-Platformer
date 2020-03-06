extends CanvasLayer

var films := {}
var scene_film := preload("res://Object/Gui/Film.tscn")

func _ready():
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

func collect_film(id: int):
	films[id].collect()
