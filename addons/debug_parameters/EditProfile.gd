@tool
extends Window

@onready var valid_button := $VBoxContainer/ValidButton
@onready var profile_text_edit := $VBoxContainer/ProfileTextEdit
signal on_validate(profile_name, popup)
signal on_close(popup)

func _ready():
	close_requested.connect(close)
	valid_button.pressed.connect(validate)

func set_profile(profile: DebugParameterProfile):
	profile_text_edit.set_text(profile.get_profile_name())
	
func close():
	on_close.emit(self)

func validate():
	on_validate.emit(profile_text_edit.get_text(), self)
