@tool
extends Window

@onready var valid_button := $VBoxContainer/ValidButton
@onready var code_edit := $VBoxContainer/CodeEdit
signal on_close(popup)

func _ready():
	close_requested.connect(close)
	valid_button.pressed.connect(close)
	popup_centered()

func set_profile(profile: DebugParameterProfile):
	for param in profile.get_params():
		code_edit.text += "\nvar "+param.get_slug()+" = DebugParameters.get_value('"+param.get_slug()+"')"
	
func close():
	on_close.emit(self)

