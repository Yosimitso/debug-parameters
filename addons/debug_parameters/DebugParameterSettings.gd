@tool
extends Panel

@onready var help_button := $GridContainer/HelpButton
var profile : DebugParameterProfile
var in_game_mode: bool
var enabled: bool

func _ready():
	help_button.pressed.connect(help)

func set_profile(_profile: DebugParameterProfile, _in_game_mode: bool):
	profile = _profile
	in_game_mode = _in_game_mode
	$GridContainer.set_visible(!in_game_mode)
	
func help():
	var popup = preload('Help.tscn').instantiate()
	add_child(popup)
	popup.set_profile(profile)
	popup.on_close.connect(close_popup)

func close_popup(popup):
	remove_child(popup)
	
func to_dict() -> Dictionary:
	return {
		'enabled': $GridContainer/EnabledCheckBox.button_pressed
	}

func load_data(data: Dictionary):
	$GridContainer/EnabledCheckBox.button_pressed = data.enabled

func is_enabled() -> bool:
	return $GridContainer/EnabledCheckBox.button_pressed
