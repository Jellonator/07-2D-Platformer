extends Control

signal on_hidden()

enum ExitMode {GO_TO_MENU, HIDE}

export(ExitMode) var exit_mode := ExitMode.GO_TO_MENU

func do_exit():
	match exit_mode:
		ExitMode.HIDE:
			hide()
			emit_signal("on_hidden")
		ExitMode.GO_TO_MENU:
			var scene = load("res://Menu/MainMenu.tscn")
			var err = get_tree().change_scene_to(scene)
			if err != OK:
				push_error("Could not load main menu [{0}]".format(err))
