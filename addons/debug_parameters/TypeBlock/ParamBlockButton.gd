@tool
extends ParamBlock

func init(label: String, tooltip: String):
	$Button.set_text(label)
	$Button.tooltip_text = tooltip
	$Button.pressed.connect(pressed)

func pressed():
	value_updated.emit()

func drop_focus():
	$Button.release_focus()
	
func get_value():
	return null
