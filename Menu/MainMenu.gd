extends Control

func _ready():
# warning-ignore:return_value_discarded
	GameConfig.connect("icon_changed", self, "on_input_changed")
	on_input_changed("action_grab")
	on_input_changed("action_jump")

func on_input_changed(name: String):
	match name:
		"action_grab":
			$BtnDelete.texture = GameConfig.get_action_icon("action_grab")
		"action_jump":
			$BtnCreate.texture = GameConfig.get_action_icon("action_jump")

