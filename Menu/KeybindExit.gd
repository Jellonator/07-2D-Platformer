extends CenterContainer

func select():
	$Button.grab_focus()

func unselect():
	$Button.release_focus()

func activate():
	owner.do_exit()

func _on_Button_pressed():
	activate()

func get_cursor_position():
	return $Button.rect_global_position
