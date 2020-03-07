extends Control

export var file_name := ""
export var title := ""

var should_load := true

func _ready():
	var fh := File.new()
	if fh.file_exists(file_name):
		should_load = true
		$Create.hide()
	else:
		should_load = false
		$Load.hide()

func select():
	if should_load:
		pass
	else:
		$Create.hide()
		$Load.show()
		should_load = false
		GameData.create_data(file_name)
	
