extends Control

export var file_name := ""
export var title := ""

var should_load := true
const KNOWN_FILMS := 10
onready var pressed := false
var is_deleting := false
onready var delete_selection := $CheckDelete/No

onready var move_nodes := [
	$Title,
	$Load/FilmCount,
	$Load/TextureRect,
	$Create/CreateLabel
]

func set_display():
	var cfg = GameData.load_to_config(file_name)
	var num = GameData.config_count_collected_films(cfg)
	$Load/FilmCount.text = "{0}/{1}".format([num, KNOWN_FILMS])

func _ready():
	$Title.text = title
	$CheckDelete/Title.text = title
	var fh := File.new()
	if fh.file_exists(file_name):
		should_load = true
		$Create.hide()
		set_display()
	else:
		should_load = false
		$Load.hide()

func do_load_game():
	GameData.load_data(file_name)
	var scene = preload("res://Menu/LevelSelect/LevelSelect.tscn")
	var err = get_tree().change_scene_to(scene)
	if err != OK:
		push_error("Could not load level select [{0}]".format(err))

func activate():
	if get_parent().is_locked():
		return
	if should_load:
		do_load_game()
	else:
		GameData.create_data(file_name)
		do_load_game()

func finalize_delete():
	if should_load:
		if delete_selection == $CheckDelete/Yes:
			$Create.show()
			$Load.hide()
			should_load = false
			var dir := Directory.new()
			var err = dir.remove(file_name)
			if err != OK:
				push_error("Could not delete save " + file_name + " [" + str(err) + "]")
			$Create.show()
			$Create.grab_focus()
		else:
			$Load.show()
			$Load.grab_focus()
		get_parent().set_locked(false)
		is_deleting = false
		$CheckDelete.hide()
		get_parent().select(get_position_in_parent())

func delete():
	if get_parent().is_locked():
		return
	if should_load:
		$CheckDelete.show()
		is_deleting = true
		get_parent().set_locked(true)
		delete_selection = $CheckDelete/No
		get_parent().force_cursor($CheckDelete/No)
		$Load.hide()
		$Create.hide()

func select():
	if get_parent().is_locked():
		return
	if should_load:
		$Load.grab_focus()
	else:
		$Create.grab_focus()
	if pressed:
		return
	pressed = true

func unselect():
	if get_parent().is_locked():
		return
	$Load.release_focus()
	$Create.release_focus()
	if not pressed:
		return
	pressed = false

var is_down := false
func _physics_process(_delta):
	if get_parent().is_locked() and get_parent().current != get_position_in_parent():
		$Create.release_focus()
		$Load.release_focus()
	$Create.disabled = get_parent().is_locked()
	$Load.disabled = get_parent().is_locked()
	var is_pressed = $Load.pressed or $Create.pressed
	if is_down and not is_pressed:
		for node in move_nodes:
			node.rect_position -= Vector2(0, 2)
	elif not is_down and is_pressed:
		for node in move_nodes:
			node.rect_position += Vector2(0, 2)
	is_down = is_pressed

func _input(event):
	if is_deleting:
		if event.is_action_pressed("move_left"):
			delete_selection = $CheckDelete/Yes
			get_parent().force_cursor($CheckDelete/Yes)
			get_parent().snd_move.play()
			accept_event()
		elif event.is_action_pressed("move_right"):
			delete_selection = $CheckDelete/No
			get_parent().force_cursor($CheckDelete/No)
			get_parent().snd_move.play()
			accept_event()
		elif event.is_action_pressed("action_jump"):
			finalize_delete()
			accept_event()
		# Default UI inputs are now activated
		elif event.is_action_pressed("ui_left"):
			delete_selection = $CheckDelete/Yes
			get_parent().force_cursor($CheckDelete/Yes)
			get_parent().snd_move.play()
			accept_event()
		elif event.is_action_pressed("ui_right"):
			delete_selection = $CheckDelete/No
			get_parent().force_cursor($CheckDelete/No)
			get_parent().snd_move.play()
			accept_event()
		elif event.is_action_pressed("ui_select") or\
				event.is_action_pressed("ui_accept"):
			finalize_delete()
			accept_event()
		

func _on_Create_pressed():
	if get_parent().is_locked():
		return
	activate()
	get_parent().select(get_position_in_parent())

func _on_Load_pressed():
	if get_parent().is_locked():
		return
	activate()
	get_parent().select(get_position_in_parent())
