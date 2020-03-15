extends Container

const scene_cursor := preload("res://Menu/Cursor.tscn")

var items := []
var cursor: Node2D
var current := 0
var snd_move: AudioStreamPlayer

func _ready():
	items = get_children()
	cursor = scene_cursor.instance()
	snd_move = AudioStreamPlayer.new()
	add_child(snd_move)
	add_child(cursor)
	snd_move.stream = preload("res://Ext/EssentialRetro/sfx_menu_move4.wav")
	snd_move.volume_db = -12
	snd_move.bus = "Sound"
	select(0)
	if items[0].has_method("select"):
		items[0].select()

func select(id: int):
	if id != current:
		if items[current].has_method("unselect"):
			items[current].unselect()
		if items[id].has_method("select"):
			items[id].select()
	current = id
	if items[id].has_method("get_cursor_position"):
		cursor.global_position = items[id].get_cursor_position()
	else:
		cursor.global_position = items[id].rect_global_position

func _input(event):
	if event.is_action_pressed("move_down"):
		select(posmod(current + 1, items.size()))
		snd_move.play()
		accept_event()
	elif event.is_action_pressed("move_up"):
		select(posmod(current - 1, items.size()))
		snd_move.play()
		accept_event()
	elif event.is_action_pressed("action_jump"):
		if items[current].has_method("activate"):
			items[current].activate()
		accept_event()
	elif event.is_action_pressed("action_grab"):
		if items[current].has_method("delete"):
			items[current].delete()
		accept_event()
	# Default UI inputs are now activated
	elif event.is_action_pressed("ui_down") or\
		 event.is_action_pressed("ui_focus_next") or\
		 event.is_action_pressed("ui_page_down"):
		select(posmod(current + 1, items.size()))
		snd_move.play()
		accept_event()
	elif event.is_action_pressed("ui_up") or\
		 event.is_action_pressed("ui_focus_prev") or\
		 event.is_action_pressed("ui_page_up"):
		select(posmod(current - 1, items.size()))
		snd_move.play()
		accept_event()
	elif event.is_action_pressed("ui_select") or\
		 event.is_action_pressed("ui_select"):
		if items[current].has_method("activate"):
			items[current].activate()
		accept_event()
	# ui_cancel -> delete intentionally left out so that player's don't
	# accidentally delete save files by pressing a button they assume is
	# not bound 
