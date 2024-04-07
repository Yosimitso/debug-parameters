@tool
extends ParamBlock

func init(label: String, tooltip: String, value: String):
	$Label.set_text(label)
	$TextEdit.set_text(value)
	$TextEdit.tooltip_text = tooltip
	$TextEdit.focus_exited.connect(focus_exited)

func focus_exited():
	value_updated.emit()

func drop_focus():
	$TextEdit.release_focus()
	
func get_value():
	return $TextEdit.get_text()
