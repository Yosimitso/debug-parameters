@tool
extends ParamBlock

func init(label: String, tooltip: String, checked: bool):
	$CheckBox.set_text(label)
	$CheckBox.tooltip_text = tooltip
	$CheckBox.button_pressed = checked
	$CheckBox.toggled.connect(focus_exited)

func focus_exited(_toggled):
	value_updated.emit()

func drop_focus():
	$CheckBox.release_focus()
	
func get_value():
	return $CheckBox.button_pressed

